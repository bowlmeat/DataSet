 

contract Doubler {

    struct Participant {
        address etherAddress;
        uint amount;
    }

    Participant[] public participants;

    uint public payoutIdx = 0;
    uint public collectedFees;
    uint public balance = 0;

    address public owner;

     
    modifier onlyowner { if (msg.sender == owner) _ }

     
    function Doubler() {
        owner = msg.sender;
    }

     
    function() {
        enter();
    }
    
    function enter() {
        if (msg.value < 1 ether) {
            msg.sender.send(msg.value);
            return;
        }

      	 
        uint idx = participants.length;
        participants.length += 1;
        participants[idx].etherAddress = msg.sender;
        participants[idx].amount = msg.value;
        
         
        if (idx != 0) {
            collectedFees += msg.value / 10;
            balance += msg.value;
        } 
        else {
             
             
            collectedFees += msg.value;
        }

	 
        if (balance > participants[payoutIdx].amount * 2) {
            uint transactionAmount = 2 * (participants[payoutIdx].amount - participants[payoutIdx].amount / 10);
            participants[payoutIdx].etherAddress.send(transactionAmount);

            balance -= participants[payoutIdx].amount * 2;
            payoutIdx += 1;
        }
    }

    function collectFees() onlyowner {
        if (collectedFees == 0) return;

        owner.send(collectedFees);
        collectedFees = 0;
    }

    function setOwner(address _owner) onlyowner {
        owner = _owner;
    }
}