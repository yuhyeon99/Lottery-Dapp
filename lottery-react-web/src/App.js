import React, {useState, useEffect} from 'react';
import logo from './logo.svg';
import './App.css';
import Web3 from 'web3';

let lotteryAddress = '0xC89C4883D9206f011cC10AeB06558845BCe8Ddfd';
let lotteryABI =  [ { "constant": true, "inputs": [], "name": "answerForTest", "outputs": [ { "name": "", "type": "bytes32" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [], "name": "owner", "outputs": [ { "name": "", "type": "address" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "inputs": [], "payable": false, "stateMutability": "nonpayable", "type": "constructor" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "index", "type": "uint256" }, { "indexed": true, "name": "bettor", "type": "address" }, { "indexed": false, "name": "amount", "type": "uint256" }, { "indexed": false, "name": "challenges", "type": "bytes1" }, { "indexed": false, "name": "answerBlockNumber", "type": "uint256" } ], "name": "BET", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "index", "type": "uint256" }, { "indexed": false, "name": "bettor", "type": "address" }, { "indexed": false, "name": "amount", "type": "uint256" }, { "indexed": false, "name": "challenges", "type": "bytes1" }, { "indexed": false, "name": "answer", "type": "bytes1" }, { "indexed": false, "name": "answerBlockNumber", "type": "uint256" } ], "name": "WIN", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "index", "type": "uint256" }, { "indexed": false, "name": "bettor", "type": "address" }, { "indexed": false, "name": "amount", "type": "uint256" }, { "indexed": false, "name": "challenges", "type": "bytes1" }, { "indexed": false, "name": "answer", "type": "bytes1" }, { "indexed": false, "name": "answerBlockNumber", "type": "uint256" } ], "name": "FAIL", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "index", "type": "uint256" }, { "indexed": false, "name": "bettor", "type": "address" }, { "indexed": false, "name": "amount", "type": "uint256" }, { "indexed": false, "name": "challenges", "type": "bytes1" }, { "indexed": false, "name": "answer", "type": "bytes1" }, { "indexed": false, "name": "answerBlockNumber", "type": "uint256" } ], "name": "DRAW", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "index", "type": "uint256" }, { "indexed": false, "name": "bettor", "type": "address" }, { "indexed": false, "name": "amount", "type": "uint256" }, { "indexed": false, "name": "challenges", "type": "bytes1" }, { "indexed": false, "name": "answerBlockNumber", "type": "uint256" } ], "name": "REFUND", "type": "event" }, { "constant": true, "inputs": [], "name": "getPot", "outputs": [ { "name": "pot", "type": "uint256" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [ { "name": "challenges", "type": "bytes1" } ], "name": "betAndDistribute", "outputs": [ { "name": "result", "type": "bool" } ], "payable": true, "stateMutability": "payable", "type": "function" }, { "constant": false, "inputs": [ { "name": "challenges", "type": "bytes1" } ], "name": "bet", "outputs": [ { "name": "result", "type": "bool" } ], "payable": true, "stateMutability": "payable", "type": "function" }, { "constant": false, "inputs": [], "name": "distribute", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "answer", "type": "bytes32" } ], "name": "setAnswerForTest", "outputs": [ { "name": "result", "type": "bool" } ], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [ { "name": "challenges", "type": "bytes1" }, { "name": "answer", "type": "bytes32" } ], "name": "isMatch", "outputs": [ { "name": "", "type": "uint8" } ], "payable": false, "stateMutability": "pure", "type": "function" }, { "constant": true, "inputs": [ { "name": "index", "type": "uint256" } ], "name": "getBetInfo", "outputs": [ { "name": "answerBlockNumber", "type": "uint256" }, { "name": "bettor", "type": "address" }, { "name": "challenges", "type": "bytes1" } ], "payable": false, "stateMutability": "view", "type": "function" } ]
function App() {

  const [web3, setWeb3] = useState(null);
  const [accounts, setAccounts] = useState([]);
  const [balance, setBalance] = useState('');
  const [account, setAccount] = useState('');
  const [lotteryContract, setLotteryContract] = useState(null);

  useEffect(() => {
    initWeb3();
  }, []);

  const initWeb3 = async () => {
    if (window.ethereum) {

      const instance = new Web3(window.ethereum);
      try {
        await window.ethereum.enable(); // 요청을 통해 계정 엑세스 권한 얻기
        setWeb3(instance);
        const accs = await instance.eth.getAccounts();
        setAccounts(accs);
        const bal = await instance.eth.getBalance(accs[0]);
        setBalance(bal);


        setAccount(accs[0]);
        
        
        const lotteryContractInstance = new instance.eth.Contract(lotteryABI, lotteryAddress);
        
        setLotteryContract(lotteryContractInstance);
        
        // call : smartcontract 에서 상태를 변경시키지 않는 값만 읽어오는 액션
        const pot = await lotteryContractInstance.methods.getPot().call();
        const owner = await lotteryContractInstance.methods.owner().call();


        lotteryContractInstance.methods.betAndDistribute('0xcd').send({from:accs[0], value:5000000000000000, gas:300000});
        
      } catch (error) {
        console.log(`User denied account access error: ${error}`);
      }
    }else{
      console.log('Non-Ethereum');
    }

    
  };
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>
    </div>
  );
}

export default App;
