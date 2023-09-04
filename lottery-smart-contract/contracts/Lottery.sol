// 버전 0.4보다 높고 0.9보다 작은 스마트 컨트렉트 사용
pragma solidity >=0.4.22 <0.9.0;


contract Lottery {

    struct BetInfo {
        uint256 answerBlockNumber;
        address payable bettor; // payable => 돈을 보내기 위한 키워드
        byte challenges; // 0xab
    }
    
    
    uint256 private _tail;
    uint256 private _head;
    // 큐 생성
    mapping (uint256 => BetInfo) private _bets;

    address payable public owner;

    bool private mode = false; // false : test mode , true : real block hash
    bytes32 public answerForTest;
    // 팟머니 저장변수
    uint256 private _pot;
    // 블록 해쉬 제한 256
    uint256 constant internal BLOCK_LIMIT = 256;
    // block interval
    uint256 constant internal BET_BLOCK_INTERVAL = 3;
    // 배팅금액 : 0.005 eth , 5 * 10의 15승 = 0.005
    uint256 constant internal BET_AMOUNT = 5 * 10 ** 15;
    

    enum BlockStatus {Checkable, NotRevealed, BlockLimitPassed}
    enum BettingResult {Fail, Win, Draw}

    event BET(uint256 index, address bettor, uint256 amount, byte challenges, uint256 answerBlockNumber);

    event WIN(uint256 index, address bettor, uint256 amount, byte challenges, byte answer, uint256 answerBlockNumber);
    event FAIL(uint256 index, address bettor, uint256 amount, byte challenges, byte answer, uint256 answerBlockNumber);
    event DRAW(uint256 index, address bettor, uint256 amount, byte challenges, byte answer, uint256 answerBlockNumber);
    event REFUND(uint256 index, address bettor, uint256 amount, byte challenges, uint256 answerBlockNumber);

    constructor() public {
        owner = msg.sender;
    }

    // 팟머니 getter
    function getPot() public view returns (uint256 pot){
        return _pot;
    }

    /** 
     * @dev 베팅과 정답 체크를 한다. 유저는 0.005 ETH를 보내야 하고, 베팅용 1 byte 글자를 보낸다.
     * 큐에 저장된 베팅 정보는 이후 distribute 함수에서 해결된다.
     * @param challenges 유저가 베티하는 글자
     * @return 함수가 잘 수행되었는지 확인하는 bool 값
     */
    function betAndDistribute(byte challenges) public payable returns (bool result) {
        bet(challenges);
        
        distribute();

        return true;
    }
    /** 
     * @dev 베팅을 한다. 유저는 0.005 ETH를 보내야 하고, 베팅용 1 byte 글자를 보낸다.
     * 큐에 저장된 베팅 정보는 이후 distribute 함수에서 해결된다.
     * @param challenges 유저가 베티하는 글자
     * @return 함수가 잘 수행되었는지 확인하는 bool 값
     */
    function bet(byte challenges) public payable returns (bool result) {
        // 돈이 제대로 왔는지 체크
        require(msg.value == BET_AMOUNT, "Not enough ETH");

        // 큐에 bet 정보 입력
        require(pushBet(challenges), "Fail to add a new Bet Info");

        // Emit event
        emit BET(_tail - 1, msg.sender, msg.value, challenges, block.number + BET_BLOCK_INTERVAL);
        
        return true;
    }

    /** 
     * @dev 베팅 결과값을 확인 하고 팟머니를 분배한다.
     * 정답 실패 : 팟머니 축적, 정답 맞춤 : 팟머니 획득, 한글자 맞춤 or 정답 확인 불가 : 베팅 금액만 획득
     */
    function distribute() public {
        // head 3 4 5 6 7 8 9 10 11 12 tail
        uint256 cur;
        uint256 transferAmount;
        BetInfo memory b;
        BlockStatus currentBlockStatus;
        BettingResult currentBettingResult;

        for(cur=_head;cur<_tail;cur++){
            b = _bets[cur];
            currentBlockStatus = getBlockStatus(b.answerBlockNumber);
            
            // 체크 가능한 상태 : block.number > AnswerBlockNumber && block.number < BLOCK_LIMIT + AnswerBlockNumber
            if(currentBlockStatus == BlockStatus.Checkable){
                bytes32 answerBlockHash = getAnswerBlockHash(b.answerBlockNumber);
                currentBettingResult = isMatch(b.challenges, answerBlockHash);
                // if win, bettor gets pot
                if(currentBettingResult == BettingResult.Win){
                    // transfer pot
                    transferAmount = transferAfterPayingFee(b.bettor, _pot + BET_AMOUNT);
                    // pot = 0
                    _pot = 0;
                    // emit WIN
                    emit WIN(cur, b.bettor, transferAmount, b.challenges, answerBlockHash[0], b.answerBlockNumber);
                }
                // if fail, bettor's money goes pot
                if(currentBettingResult == BettingResult.Fail){
                    // pot = pot + BET_AMOUNT
                    _pot += BET_AMOUNT;
                    // emit FAIL
                    emit FAIL(cur, b.bettor, 0, b.challenges, answerBlockHash[0], b.answerBlockNumber);
                }
                // if draw, bettor's money
                if(currentBettingResult == BettingResult.Draw){
                    // transfer only BET_AMOUNT
                    transferAmount = transferAfterPayingFee(b.bettor, BET_AMOUNT);
                    // emit DRAW
                    emit DRAW(cur, b.bettor, transferAmount, b.challenges, answerBlockHash[0], b.answerBlockNumber);
                }
            }
            // 아직 마이닝 되지 않았을 때 : block.number <= AnswerBlockNumber 
            if(currentBlockStatus == BlockStatus.NotRevealed){
                break;
            }
            // 블록이 제한이 지났을 때 : block.number >= AnswerBlockNumber + BLOCK_LIMIT
            if(currentBlockStatus == BlockStatus.BlockLimitPassed){
                // refund
                transferAmount = transferAfterPayingFee(b.bettor, BET_AMOUNT);
                // emit refund
                emit REFUND(cur, b.bettor, transferAmount, b.challenges, b.answerBlockNumber);
            }

            popBet(cur);
        }
        _head = cur;
    }

    function transferAfterPayingFee(address payable addr, uint256 amount) internal returns (uint256){

        // uint256 fee = amount / 100;
        uint256 fee = 0;
        uint256 amountWithoutFee = amount - fee;

        // transfer to addr
        addr.transfer(amountWithoutFee);

        // transfer to owner
        owner.transfer(fee);

        // call, send, transfer => 이더를 전송하는 세가지 방법 매우 조심히 사용해야 함

        return amountWithoutFee;
    }

    function setAnswerForTest(bytes32 answer) public returns (bool result){
        require(msg.sender == owner, "Only owner만 테스트 모드에서의 answer을 설정 가능");
        answerForTest = answer;
        return true;
    }

    function getAnswerBlockHash(uint256 answerBlockNumber) internal view returns (bytes32 answer){
        return mode ? blockhash(answerBlockNumber) : answerForTest;
    }

    /** 
     * @dev 베팅글자와 정답을 확인한다.
     * @param challenges 베팅 글자
     * @param answer 블록해쉬값
     * @return 정답결과
    */
    function isMatch(byte challenges, bytes32 answer) public pure returns (BettingResult){
        // challenges 0xab
        // answer 0xab......ff 32 bytes

        byte c1 = challenges;
        byte c2 = challenges;
        byte a1 = answer[0];
        byte a2 = answer[0];

        // Get first number
        c1 = c1 >> 4; // 0xab -> 0x0a
        c1 = c1 << 4; // 0x0a -> 0xa0

        a1 = a1 >> 4;
        a1 = a1 << 4; 

        // Get Second number
        c2 = c2 << 4; // 0xab -> 0xb0
        c2 = c2 >> 4; // 0xb0 -> 0x0b

        a2 = a2 << 4;
        a2 = a2 >> 4;

        if(a1 == c1 && a2 == c2){
            return BettingResult.Win;
        }

        if(a1 == c1 || a2 == c2){
            return BettingResult.Draw;
        }

        return BettingResult.Fail;
    }

    function getBlockStatus(uint256 answerBlockNumber) internal view returns(BlockStatus){
        if(block.number > answerBlockNumber && block.number < BLOCK_LIMIT + answerBlockNumber){
            return BlockStatus.Checkable;
        }

        if(block.number <= answerBlockNumber){
            return BlockStatus.NotRevealed;
        }

        if(block.number >= answerBlockNumber + BLOCK_LIMIT){
            return BlockStatus.BlockLimitPassed;
        }

        return BlockStatus.BlockLimitPassed;
    }
        
    function getBetInfo(uint256 index) public view returns (uint256 answerBlockNumber, address bettor, byte challenges){
        BetInfo memory b = _bets[index];
        answerBlockNumber = b.answerBlockNumber;
        bettor = b.bettor;
        challenges = b.challenges;
    }

    function pushBet(byte challenges) public returns (bool){
        BetInfo memory b;
        b.bettor = msg.sender; // 20byte
        b.answerBlockNumber = block.number + BET_BLOCK_INTERVAL; // block.number = 현재 사용하는 block 의 number , 32byte 20000 gas
        b.challenges = challenges; // byte // 20000 gas

        _bets[_tail] = b;
        _tail++; // 32byte 값 변화 // 20000 gas

        return true;
    }

    function popBet(uint256 index) public returns (bool){
        delete _bets[index];
        return true;
    }
}