pragma solidity ^0.4.24;
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

    function bet(byte char) {
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
 