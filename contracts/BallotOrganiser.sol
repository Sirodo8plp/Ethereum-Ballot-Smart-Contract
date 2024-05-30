// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract BallotOrganiser {
    struct Vote {
        address PersonAddress;
        bool Value;
    }
    struct Ballot {
        bytes32 Identifier;
        string Subject;
        bool IsOpen;
        address CreatedBy;
        address ClosedBy;
    }

    mapping(bytes32 => Ballot) internal Ballots;
    mapping(bytes32 => Vote[]) internal BallotVotes;
    mapping (bytes32 => bool) internal ExistingBallots;

    function EnsureThatBallotIsNew(string memory _subject) internal view
    {
        bytes32 id = GetBallotId(_subject);
        
        require(ExistingBallots[id] == false, "Each ballot's subject is unique.");
    }

    function EnsureThatBallotExists(string memory _subject) internal view
    {
        bytes32 id = GetBallotId(_subject);
        
        require(ExistingBallots[id] == true, "The ballot requested does not exist.");
    }

    function GetBallotId(string memory _subject) internal pure returns(bytes32) 
    {
        return keccak256(abi.encodePacked(_subject));
    }

    function AddBallot(string memory _subject) external
    {
        bytes32 id = GetBallotId(_subject);
        
        require(ExistingBallots[id] == false, "Each ballot's subject is unique.");

        Ballots[id] = Ballot(
            id,
            _subject,
            true,
            msg.sender,
            0x0000000000000000000000000000000000000000
        );

        ExistingBallots[id] = true;
    }

    function HasUserVotedToBallot(Vote[] storage ballotVotes, address _user) private view returns (bool)
    {
        for (uint256 i = 0; i < ballotVotes.length; i++)
        {
            if (ballotVotes[i].PersonAddress == _user){
                return true;
            }
        }

        return false;
    }

    function VoteToBallot(bool vote, string memory _subject) external
    {
        bytes32 id = GetBallotId(_subject);

        EnsureThatBallotExists(_subject);

        require(Ballots[id].IsOpen == true, "The request ballot is not open");

        require(HasUserVotedToBallot(BallotVotes[id], msg.sender) == false, "You can only vote once at a ballot");

        BallotVotes[id].push(Vote(msg.sender, vote));
    }

    function CloseBallot(string memory _subject) external
    {
        bytes32 id = GetBallotId(_subject);

        EnsureThatBallotExists(_subject);

        require(Ballots[id].CreatedBy == msg.sender, "Only the creator of the ballot can close it.");

        Ballots[id].IsOpen = false;
        Ballots[id].ClosedBy = msg.sender;
    }

    function GetBallotVotes(string memory _subject) external view returns (uint,bool)
    {
        bytes32 id = GetBallotId(_subject);

        EnsureThatBallotExists(_subject);

        int256 falseCount = 0;
        int256 trueCount = 0;

        for (uint256 i = 0; i < BallotVotes[id].length; i++)
        {
            if (BallotVotes[id][i].Value == true){
                trueCount += 1;
            }
            else 
            {
                falseCount += 1;
            }
        }

        return (BallotVotes[id].length,trueCount>=falseCount);
    }
}