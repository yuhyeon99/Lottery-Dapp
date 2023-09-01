// 버전 0.4보다 높고 0.9보다 작은 스마트 컨트렉트 사용
pragma solidity >=0.4.22 <0.9.0;


contract Lottery {
    
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function getSomeValue() public pure returns (uint256 value){
        return 5;
    }
}