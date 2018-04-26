pragma solidity ^0.4.11;

contract Casino {


    uint public minimumBet = 100 finney; // Equal to 0.1 ether

   // The total amount of Ether bet for this current game
   uint public totalBet;

   // The total number of bets the users have made
   uint public numberOfBets;

   // The maximum amount of bets can be made for each game
   uint public maximumAmountsOfBets = 10;
    address[] players;

    struct Player {

        uint amountBet;
        uint numberSelected;
    }


    mapping(address => Player) playerInfo;


    address owner; // Long string from metamask


    function Casino(uint _minimumBet) public{  // Constructor : has the same name as the contract , used to set up
        //contract owner

        owner = msg.sender;
        if(_minimumBet !=0) minimumBet = _minimumBet;

        }

        //To be for a number btw 1 & 10 both inclusive


    function bet(uint number) payable public {

        require(!checkPlayerExists(msg.sender) );
        require(number >= 1 && number <= 10);
        require(msg.value >= minimumBet);


        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].numberSelected = number;
        numberOfBets += 1;
        players.push(msg.sender);
        totalBet += msg.value;

        if(numberOfBets >= maximumAmountsOfBets) generateNumberWinner();


        }



    function checkPlayerExists(address player) public view returns(bool) {

        for( uint i = 0 ; i < players.length; i++){
            if(players[i] == player) return true;
        }
        return false;
    }


    /*
    Generate Winner : Generates a number between 1 & 10
    */

    function generateNumberWinner() public{

        uint numberGenerated = block.number % 10 + 1; // This isnt secure

        distributePrizes(numberGenerated);
    }


    /*

    Distribute Prizes : Sends the correspondng ether to each winner
    depending on the total bets
    */

    function distributePrizes(uint numberWinner) public {

        address[100] memory winners ; // We have to create a temporary in memory array with fixed size

        uint count = 0; // This is the count for the array of winners

        for(uint i = 0; i < players.length ; i++) {
            address playerAddress = players[i];
            if(playerInfo[playerAddress].numberSelected == numberWinner){
                winners[count] = playerAddress;
                count ++;
            }
            delete playerInfo[playerAddress]; // Delete all the players array


        }



        uint winnerEtherAmount = totalBet / winners.length; // How much each player gets

        for(uint j = 0; j < count; j++) {

            if(winners[j] !=address(0)) // Check the address in the fixed array is not empty
            winners[j].transfer(winnerEtherAmount);
        }

        players.length = 0; //Delete all the players array
        totalBet = 0;
        numberOfBets = 0;

    }

    /*
    Annonymous Fallback function: In case someone sends ether to the
    contract so it doesnt get lost
    */
    function() payable private{}

/*
Kill function: Used to destroy contract whenever we want. Only owner
has the ability to kill the contract
*/

    function kill() public{

        if(msg.sender == owner)
            selfdestruct(owner);
    }
}
