// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract BallotOrganiser {
    struct Vote {
        address PersonAddress;
        bool Value;
    }
    struct Ballot {
        string Subject;
        bool IsOpen;
        address CreatedBy;
        address ClosedBy;
    }
    //ballot's subject => ballot
    mapping(string => Ballot) internal Ballots;
    mapping(string => Vote[]) internal BallotVotes;
    mapping (string => bool) internal ExistingBallots;

    uint64 private BallotIdentifierCounter = 0;

    function EnsureThatBallotExists(string calldata ballotSubject) internal view
    {
        require(ExistingBallots[ballotSubject] == true, "The ballot requested does not exist.");
    }

    function AddBallot(string memory _subject) external
    {
        require(ExistingBallots[_subject] == false, "Each ballot's subject is unique.");

        Ballots[_subject] = Ballot(
            _subject,
            true,
            msg.sender,
            0x0000000000000000000000000000000000000000
        );

        ExistingBallots[_subject] = true;
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

    function VoteToBallot(bool vote, string calldata ballotSubject) external
    {
        EnsureThatBallotExists(ballotSubject);

        require(Ballots[ballotSubject].IsOpen == true, "The request ballot is not open");

        require(HasUserVotedToBallot(BallotVotes[ballotSubject], msg.sender) == false, "You can only vote once at a ballot");

        BallotVotes[ballotSubject].push(Vote(msg.sender, vote));
    }

    function CloseBallot(string calldata ballotSubject) external
    {
        EnsureThatBallotExists(ballotSubject);

        require(Ballots[ballotSubject].CreatedBy == msg.sender, "Only the creator of the ballot can close it.");

        Ballots[ballotSubject].IsOpen = false;
        Ballots[ballotSubject].ClosedBy = msg.sender;
    }

    function GetBallotVotes(string calldata ballotIdentifier) external view returns (uint,bool)
    {
        EnsureThatBallotExists(ballotIdentifier);

        int256 falseCount = 0;
        int256 trueCount = 0;

        for (uint256 i = 0; i < BallotVotes[ballotIdentifier].length; i++)
        {
            if (BallotVotes[ballotIdentifier][i].Value == true){
                trueCount += 1;
            }
            else 
            {
                falseCount += 1;
            }
        }

        return (BallotVotes[ballotIdentifier].length,trueCount>=falseCount);
    }
}