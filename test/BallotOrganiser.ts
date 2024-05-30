import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
  import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
  import { expect } from "chai";
  import hre from "hardhat";
  
  describe("Ballot Organiser", function () {
    async function deployOneYearLockFixture() {
        const [owner, otherAccount] = await hre.ethers.getSigners();

        const BallotOrganiser = await hre.ethers.getContractFactory("BallotOrganiser");
        const ballotOrganiser = await BallotOrganiser.deploy();
  
        return { ballotOrganiser, otherAccount };
    }

    describe("AddBallot", function () {
        it("Should successfully add a new ballot", async function () {
            const { ballotOrganiser } = await loadFixture(deployOneYearLockFixture);
    
            await expect(ballotOrganiser.AddBallot("test ballot")).to.not.be.reverted;
        });

        it("Should not add a ballot with a subject that already exists", async function () {
            const { ballotOrganiser } = await loadFixture(deployOneYearLockFixture);
    
            await expect(ballotOrganiser.AddBallot("test ballot")).to.not.be.reverted;

            await expect(ballotOrganiser.AddBallot("test ballot"))
            .to
            .be
            .revertedWith("Each ballot's subject is unique.");
        });
    });

    describe("VoteToBallot", function () {
        it("Should successfully create and vote \"Yes\" to an existing ballot", async function () {
            const { ballotOrganiser } = await loadFixture(deployOneYearLockFixture);
    
            await expect(ballotOrganiser.AddBallot("test ballot")).to.not.be.reverted;

            await (expect(ballotOrganiser.VoteToBallot(true,"test ballot"))).to.not.be.reverted;
        });

        it("Should successfully vote \"No\" to an existing ballot", async function () {
            const { ballotOrganiser } = await loadFixture(deployOneYearLockFixture);
    
            await expect(ballotOrganiser.AddBallot("test ballot")).to.not.be.reverted;

            await (expect(ballotOrganiser.VoteToBallot(false,"test ballot"))).to.not.be.reverted;
        });

        it("Should not allow user to vote two times at the same ballot", async function () {
            const { ballotOrganiser } = await loadFixture(deployOneYearLockFixture);
    
            await expect(ballotOrganiser.AddBallot("test ballot")).to.not.be.reverted;

            await (expect(ballotOrganiser.VoteToBallot(false,"test ballot"))).to.not.be.reverted;

            await (expect(ballotOrganiser.VoteToBallot(false,"test ballot")))
                .to
                .be
                .revertedWith("You can only vote once at a ballot");
        });

        it("Should not vote at a closed ballot", async function () {
            const { ballotOrganiser } = await loadFixture(deployOneYearLockFixture);
    
            await expect(ballotOrganiser.AddBallot("test ballot")).to.not.be.reverted;

            await (expect(ballotOrganiser.CloseBallot("test ballot"))).to.not.be.reverted;

            await (expect(ballotOrganiser.VoteToBallot(false,"test ballot")))
                .to
                .be
                .revertedWith("The request ballot is not open");
        });

        it("Should not vote at a ballot that does not exist", async function () {
            const { ballotOrganiser } = await loadFixture(deployOneYearLockFixture);

            await (expect(ballotOrganiser.VoteToBallot(false,"test ballot")))
                .to
                .be
                .revertedWith("The ballot requested does not exist.");
        });
    });

    describe("CloseBallot", function () {
        it("Should successfully close an existing ballot", async function () {
            const { ballotOrganiser } = await loadFixture(deployOneYearLockFixture);
    
            await expect(ballotOrganiser.AddBallot("test ballot")).to.not.be.reverted;

            await expect(ballotOrganiser.CloseBallot("test ballot")).to.not.be.reverted;
        });

        it("Should not close a ballot that has not been created", async function () {
            const { ballotOrganiser } = await loadFixture(deployOneYearLockFixture);

            await expect(ballotOrganiser.CloseBallot("test ballot"))
            .to
            .be
            .revertedWith("The ballot requested does not exist.");
        });

        it("Should close a ballot only if called by the ballot's creator", async function () {
            const { ballotOrganiser, otherAccount } = await loadFixture(deployOneYearLockFixture);

            await expect(ballotOrganiser.AddBallot("test ballot")).to.not.be.reverted;

            await expect(ballotOrganiser.connect(otherAccount).CloseBallot("test ballot"))
            .to
            .be
            .revertedWith("Only the creator of the ballot can close it.");
        });
    });

    describe("GetBallotVotes", function () {
        it("Should revert when the ballot does not exist", async function () {
            const { ballotOrganiser } = await loadFixture(deployOneYearLockFixture);

            await expect(ballotOrganiser.GetBallotVotes("test ballot"))
                .to
                .be
                .revertedWith("The ballot requested does not exist.");
        });

        it("Should return the correct number of votes", async function () {
            const { ballotOrganiser } = await loadFixture(deployOneYearLockFixture);

            await expect(ballotOrganiser.AddBallot("test ballot")).to.not.be.reverted;

            await expect(ballotOrganiser.VoteToBallot(true, "test ballot")).to.not.be.reverted;
            
            var voteResults = await ballotOrganiser.GetBallotVotes("test ballot");

            expect(Number.parseInt(voteResults[0].toString()) == 1 && voteResults[1] == true)
                .to
                .be
                .equal(true);
        });
    });
  });