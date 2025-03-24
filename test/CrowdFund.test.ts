import { expect } from "chai";
import hre from "hardhat";
import { CrowdFund, User } from "../typechain-types";
import { it } from "mocha";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";

describe('CrowdFund', function () {

    const { ethers } = hre;

    let crowdFund: CrowdFund;
    let userContract: User;
    let owner: HardhatEthersSigner;
    let user: HardhatEthersSigner;
    let user2: HardhatEthersSigner;

    before(async function () {

        // Deploy the User contract
        const User = await ethers.getContractFactory("User");
        userContract = await User.deploy();
        
        // Deploy the CrowdFund contract
        const CrowdFund = await ethers.getContractFactory('CrowdFund');
        crowdFund = await CrowdFund.deploy(userContract.getAddress());

        // Get signers
        [owner, user, user2] = await ethers.getSigners();
    });

    it("Should create a new Campaign", async () => {

        // Register user
        await userContract.connect(user).setUser("User", "user1@gmail.com");

        // Args
        const nameCampaign = "Galang Dana Pribadi";
        const description = "-";
        const targetFund = ethers.parseEther("1")
        const deadline = Math.floor(Date.now() / 1000) + 86400; // 1 hari dari sekarang

        // Create campaign
        await expect(
            crowdFund.connect(user).createCampaign(nameCampaign, description, targetFund, deadline)
        ).to.emit(crowdFund, "CampaignCreated") // apakah memicu event CampaignCreated
            .withArgs(user.address, 1, nameCampaign, description, targetFund, deadline)
        // cek apakah argumen yang diterima sesuai dengan args nya

        // Verify campaign details
        const campaign = await crowdFund.crowdFunds(user.address, 0);
        expect(campaign.creator).to.equal(user.address);
        expect(campaign.campaignId).to.equal(1);
        expect(campaign.nameCampaign).to.equal(nameCampaign);
        expect(campaign.description).to.equal(description);
        expect(campaign.targetFund).to.equal(targetFund);
        expect(campaign.currentFund).to.equal(0);
        expect(campaign.deadline).to.equal(deadline);
    });

    it("Should update campaign details successfully", async () => {

        const campaignId = 1;
        const newNameCampaign = 'New Updated Name';
        const newDescription = 'New Updated Description';
        const newTargetFund = ethers.parseEther("2");
        const newDeadline = Math.floor(Date.now() / 1000) + 86400;

        await expect(
            crowdFund.connect(user).updateCampaign(campaignId, newNameCampaign, newDescription, newTargetFund, newDeadline)
        ).to.emit(crowdFund, "CampaignUpdated")
            .withArgs(campaignId, newNameCampaign, newDescription, newTargetFund, newDeadline)

        const campaign = await crowdFund.crowdFunds(user.address, 0);
        expect(campaign.creator).to.equal(user.address);
        expect(campaign.campaignId).to.equal(campaignId);
        expect(campaign.nameCampaign).to.equal(newNameCampaign);
        expect(campaign.description).to.equal(newDescription);
        expect(campaign.targetFund).to.equal(newTargetFund);
        expect(campaign.deadline).to.equal(newDeadline);
    });

    it("should only update non-empty fields", async function () {

        const campaignId = 1;
        const newName = ""; // Kosong, tidak update
        const newDescription = "Partially Updated";
        const newTargetFund = 0; // Nol, tidak update
        const newDeadline = 1700000000;

        await expect(
            crowdFund.connect(user).updateCampaign(campaignId, newName, newDescription, newTargetFund, newDeadline)
        ).to.emit(crowdFund, "CampaignUpdated")
            .withArgs(
                campaignId,
                newName,
                newDescription,
                newTargetFund,
                newDeadline
            );

        const campaign = await crowdFund.crowdFunds(user.address, 0);
        expect(campaign.creator).to.equal(user.address);
        expect(campaign.campaignId).to.equal(campaignId);
        expect(campaign.description).to.equal(newDescription);
        expect(campaign.deadline).to.equal(newDeadline);

    });

});