const fixedMinePool = artifacts.require("fixedMinePool_test");
const CFNX = artifacts.require("CFNX");
const BN = require("bn.js");
let PeriodTime = 90*86400;
contract('fixedMinePool', function (accounts){
    it('fixedMinePool Locked stake FPTB function', async function (){
        let CFNXA = await CFNX.new();
        let CFNXB = await CFNX.new();
        let USDC = await CFNX.new();
        let startTime = 10000000;
        let minePool = await fixedMinePool.new(CFNXA.address,CFNXB.address,USDC.address,startTime);
        await CFNXA.mint(accounts[0],1000000000000000);
        await CFNXA.approve(minePool.address,1000000000000000);
        await CFNXB.mint(accounts[0],1000000000000000);
        await CFNXB.approve(minePool.address,1000000000000000);
        let nowId = await minePool.getCurrentPeriodID();
        await minePool.stakeFPTA(100000);;
        await minePool.stakeFPTB(100000,2);
        let fptA = await minePool.getUserFPTABalance(accounts[0]);
        let fptB = await minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),100000,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),100000,"getUserFPTBBalance Error");
        let userPeriodId = await minePool.getUserMaxPeriodId(accounts[0]);
        assert.equal(userPeriodId.toNumber(),nowId.toNumber()+1,"getUserMaxPeriodId Error");
        let result = await minePool.getDistributionCal(accounts[0]);
        assert.equal(result[0].toString(),"100000000","getDistributionCal Error");
        assert.equal(result[1].toString(),"2100000000","getDistributionCal Error");
        result = await minePool.getFPTADistribution();
        assert.equal(result.toString(),"100000000","getFPTADistribution Error");
        result = await minePool.getFPTBFlexibleDistribution();
        assert.equal(result.toString(),"0","getFPTBFlexibleDistribution Error");
        result = await minePool.getCurrentPeriodDistribution();
        assert.equal(result.toString(),"2100000000","getCurrentPeriodDistribution Error");
        result = await minePool.getPeriodDistribution(nowId.toNumber()+1);
        assert.equal(result.toString(),"2100000000","getPeriodDistribution Error");
        result = await minePool.getPeriodDistribution(nowId.toNumber()+2);
        assert.equal(result.toString(),"0","getPeriodDistribution Error");
        result = await minePool.getUserDistribution(accounts[0],nowId);
        assert.equal(result.toString(),"2200000000","getUserDistribution Error");
        await minePool.stakeFPTB(100000,2);
        fptA = await minePool.getUserFPTABalance(accounts[0]);
        fptB = await minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),100000,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),200000,"getUserFPTBBalance Error");
        contractBalance = await CFNXB.balanceOf(minePool.address);
        assert.equal(contractBalance.toNumber(),200000,"getUserFPTABalance Error");
        result = await minePool.getDistributionCal(accounts[0]);
        assert.equal(result[0].toString(),"100000000","getDistributionCal Error");
        assert.equal(result[1].toString(),"2200000000","getDistributionCal Error");
        result = await minePool.getFPTBFlexibleDistribution();
        assert.equal(result.toString(),"0","getFPTBFlexibleDistribution Error");
        result = await minePool.getFPTADistribution();
        assert.equal(result.toString(),"100000000","getFPTADistribution Error");
        result = await minePool.getCurrentPeriodDistribution();
        assert.equal(result.toString(),"2200000000","getCurrentPeriodDistribution Error");
        result = await minePool.getPeriodDistribution(nowId.toNumber()+1);
        assert.equal(result.toString(),"2200000000","getPeriodDistribution Error");
        result = await minePool.getPeriodDistribution(nowId.toNumber()+2);
        assert.equal(result.toString(),"0","getPeriodDistribution Error");
        result = await minePool.getUserDistribution(accounts[0],nowId);
        assert.equal(result.toString(),"2300000000","getUserDistribution Error");
        result = await minePool.getPeriodWeightDistribution(nowId.toNumber());
        assert.equal(result.toString(),"13700000000","getPeriodWeightDistribution Error");
        result = await minePool.getPeriodWeightDistribution(nowId.toNumber()+1);
        assert.equal(result.toString(),"11400000000","getPeriodWeightDistribution Error");
        result = await minePool.getPeriodWeightDistribution(nowId.toNumber()+2);
        assert.equal(result.toString(),"0","getPeriodWeightDistribution Error");
        await minePool.unstakeFPTB(100000);
        fptA = await minePool.getUserFPTABalance(accounts[0]);
        fptB = await minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),100000,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),100000,"getUserFPTBBalance Error");
        contractBalance = await CFNXB.balanceOf(minePool.address);
        assert.equal(contractBalance.toNumber(),100000,"getUserFPTABalance Error");
        result = await minePool.getDistributionCal(accounts[0]);
        assert.equal(result[0].toString(),"100000000","getDistributionCal Error");
        assert.equal(result[1].toString(),"2100000000","getDistributionCal Error");
        result = await minePool.getFPTBFlexibleDistribution();
        assert.equal(result.toString(),"0","getFPTBFlexibleDistribution Error");
        result = await minePool.getCurrentPeriodDistribution();
        assert.equal(result.toString(),"2100000000","getCurrentPeriodDistribution Error");
        result = await minePool.getPeriodDistribution(nowId.toNumber()+1);
        assert.equal(result.toString(),"2100000000","getPeriodDistribution Error");
        result = await minePool.getPeriodDistribution(nowId.toNumber()+2);
        assert.equal(result.toString(),"0","getPeriodDistribution Error");
        result = await minePool.getPeriodWeightDistribution(nowId.toNumber());
        assert.equal(result.toString(),"13100000000","getPeriodWeightDistribution Error");
        result = await minePool.getPeriodWeightDistribution(nowId.toNumber()+1);
        assert.equal(result.toString(),"10900000000","getPeriodWeightDistribution Error");
        result = await minePool.getPeriodWeightDistribution(nowId.toNumber()+2);
        assert.equal(result.toString(),"0","getPeriodWeightDistribution Error");
        result = await minePool.getUserDistribution(accounts[0],nowId);
        assert.equal(result.toString(),"2200000000","getUserDistribution Error");
        await minePool.unstakeFPTB(100000);
        fptA = await minePool.getUserFPTABalance(accounts[0]);
        fptB = await minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),100000,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),0,"getUserFPTBBalance Error");
        contractBalance = await CFNXA.balanceOf(minePool.address);
        assert.equal(contractBalance.toNumber(),100000,"getUserFPTABalance Error");
        result = await minePool.getDistributionCal(accounts[0]);
        assert.equal(result[0].toString(),"100000000","getDistributionCal Error");
        assert.equal(result[1].toString(),"0","getDistributionCal Error");
        result = await minePool.getFPTBFlexibleDistribution();
        assert.equal(result.toString(),"0","getFPTBFlexibleDistribution Error");
        result = await minePool.getCurrentPeriodDistribution();
        assert.equal(result.toString(),"0","getCurrentPeriodDistribution Error");
        result = await minePool.getPeriodDistribution(nowId.toNumber()+1);
        assert.equal(result.toString(),"0","getPeriodDistribution Error");
        result = await minePool.getPeriodDistribution(nowId.toNumber()+2);
        assert.equal(result.toString(),"0","getPeriodDistribution Error");
        result = await minePool.getUserDistribution(accounts[0],nowId);
        assert.equal(result.toString(),"100000000","getUserDistribution Error");
    });
    it('fixedMinePool Locked stake FPTB function unStakeA', async function (){
        let CFNXA = await CFNX.new();
        let CFNXB = await CFNX.new();
        let USDC = await CFNX.new();
        let startTime = 10000000;
        let minePool = await fixedMinePool.new(CFNXA.address,CFNXB.address,USDC.address,startTime);
        await CFNXA.mint(accounts[0],1000000000000000);
        await CFNXA.approve(minePool.address,1000000000000000);
        await CFNXB.mint(accounts[0],1000000000000000);
        await CFNXB.approve(minePool.address,1000000000000000);
        let nowId = await minePool.getCurrentPeriodID();
        await minePool.stakeFPTA(100000);;
        await minePool.stakeFPTB(100000,2);
        let fptA = await minePool.getUserFPTABalance(accounts[0]);
        let fptB = await minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),100000,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),100000,"getUserFPTBBalance Error");
        let userPeriodId = await minePool.getUserMaxPeriodId(accounts[0]);
        assert.equal(userPeriodId.toNumber(),nowId.toNumber()+1,"getUserMaxPeriodId Error");
        let result = await minePool.getDistributionCal(accounts[0]);
        assert.equal(result[0].toString(),"100000000","getDistributionCal Error");
        assert.equal(result[1].toString(),"2100000000","getDistributionCal Error");
        result = await minePool.getFPTADistribution();
        assert.equal(result.toString(),"100000000","getFPTADistribution Error");
        result = await minePool.getFPTBFlexibleDistribution();
        assert.equal(result.toString(),"0","getFPTBFlexibleDistribution Error");
        result = await minePool.getCurrentPeriodDistribution();
        assert.equal(result.toString(),"2100000000","getCurrentPeriodDistribution Error");
        result = await minePool.getPeriodDistribution(nowId.toNumber()+1);
        assert.equal(result.toString(),"2100000000","getPeriodDistribution Error");
        result = await minePool.getPeriodDistribution(nowId.toNumber()+2);
        assert.equal(result.toString(),"0","getPeriodDistribution Error");
        result = await minePool.getUserDistribution(accounts[0],nowId);
        assert.equal(result.toString(),"2200000000","getUserDistribution Error");
        await minePool.stakeFPTA(100000);
        fptA = await minePool.getUserFPTABalance(accounts[0]);
        fptB = await minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),200000,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),100000,"getUserFPTBBalance Error");
        contractBalance = await CFNXA.balanceOf(minePool.address);
        assert.equal(contractBalance.toNumber(),200000,"getUserFPTABalance Error");
        result = await minePool.getDistributionCal(accounts[0]);
        assert.equal(result[0].toString(),"200000000","getDistributionCal Error");
        assert.equal(result[1].toString(),"2100000000","getDistributionCal Error");
        result = await minePool.getFPTBFlexibleDistribution();
        assert.equal(result.toString(),"0","getFPTBFlexibleDistribution Error");
        result = await minePool.getFPTADistribution();
        assert.equal(result.toString(),"200000000","getFPTADistribution Error");
        result = await minePool.getCurrentPeriodDistribution();
        assert.equal(result.toString(),"2100000000","getCurrentPeriodDistribution Error");
        result = await minePool.getPeriodDistribution(nowId.toNumber()+1);
        assert.equal(result.toString(),"2100000000","getPeriodDistribution Error");
        result = await minePool.getPeriodDistribution(nowId.toNumber()+2);
        assert.equal(result.toString(),"0","getPeriodDistribution Error");
        result = await minePool.getUserDistribution(accounts[0],nowId);
        assert.equal(result.toString(),"2300000000","getUserDistribution Error");
        result = await minePool.getPeriodWeightDistribution(nowId.toNumber());
        assert.equal(result.toString(),"13600000000","getPeriodWeightDistribution Error");
        result = await minePool.getPeriodWeightDistribution(nowId.toNumber()+1);
        assert.equal(result.toString(),"11300000000","getPeriodWeightDistribution Error");
        result = await minePool.getPeriodWeightDistribution(nowId.toNumber()+2);
        assert.equal(result.toString(),"0","getPeriodWeightDistribution Error");
        await minePool.unstakeFPTA(100000);
        fptA = await minePool.getUserFPTABalance(accounts[0]);
        fptB = await minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),100000,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),100000,"getUserFPTBBalance Error");
        contractBalance = await CFNXB.balanceOf(minePool.address);
        assert.equal(contractBalance.toNumber(),100000,"getUserFPTABalance Error");
        result = await minePool.getDistributionCal(accounts[0]);
        assert.equal(result[0].toString(),"100000000","getDistributionCal Error");
        assert.equal(result[1].toString(),"2100000000","getDistributionCal Error");
        result = await minePool.getFPTBFlexibleDistribution();
        assert.equal(result.toString(),"0","getFPTBFlexibleDistribution Error");
        result = await minePool.getCurrentPeriodDistribution();
        assert.equal(result.toString(),"2100000000","getCurrentPeriodDistribution Error");
        result = await minePool.getPeriodDistribution(nowId.toNumber()+1);
        assert.equal(result.toString(),"2100000000","getPeriodDistribution Error");
        result = await minePool.getPeriodDistribution(nowId.toNumber()+2);
        assert.equal(result.toString(),"0","getPeriodDistribution Error");
        result = await minePool.getPeriodWeightDistribution(nowId.toNumber());
        assert.equal(result.toString(),"13100000000","getPeriodWeightDistribution Error");
        result = await minePool.getPeriodWeightDistribution(nowId.toNumber()+1);
        assert.equal(result.toString(),"10900000000","getPeriodWeightDistribution Error");
        result = await minePool.getPeriodWeightDistribution(nowId.toNumber()+2);
        assert.equal(result.toString(),"0","getPeriodWeightDistribution Error");
        result = await minePool.getUserDistribution(accounts[0],nowId);
        assert.equal(result.toString(),"2200000000","getUserDistribution Error");
        await minePool.unstakeFPTA(100000);
        fptA = await minePool.getUserFPTABalance(accounts[0]);
        fptB = await minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),0,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),100000,"getUserFPTBBalance Error");
        contractBalance = await CFNXB.balanceOf(minePool.address);
        assert.equal(contractBalance.toNumber(),100000,"getUserFPTABalance Error");
        result = await minePool.getDistributionCal(accounts[0]);
        assert.equal(result[0].toString(),"0","getDistributionCal Error");
        assert.equal(result[1].toString(),"100000000","getDistributionCal Error");
        result = await minePool.getFPTBFlexibleDistribution();
        assert.equal(result.toString(),"0","getFPTBFlexibleDistribution Error");
        result = await minePool.getCurrentPeriodDistribution();
        assert.equal(result.toString(),"100000000","getCurrentPeriodDistribution Error");
        result = await minePool.getPeriodDistribution(nowId.toNumber()+1);
        assert.equal(result.toString(),"100000000","getPeriodDistribution Error");
        result = await minePool.getPeriodDistribution(nowId.toNumber()+2);
        assert.equal(result.toString(),"0","getPeriodDistribution Error");
        result = await minePool.getUserDistribution(accounts[0],nowId);
        assert.equal(result.toString(),"100000000","getUserDistribution Error");
        result = await minePool.getPeriodWeightDistribution(nowId.toNumber());
        assert.equal(result.toString(),"600000000","getPeriodWeightDistribution Error");
        result = await minePool.getPeriodWeightDistribution(nowId.toNumber()+1);
        assert.equal(result.toString(),"500000000","getPeriodWeightDistribution Error");
        result = await minePool.getPeriodWeightDistribution(nowId.toNumber()+2);
        assert.equal(result.toString(),"0","getPeriodWeightDistribution Error");
    });
    it('fixedMinePool Locked stake FPTB function changePeriod', async function (){
        let CFNXA = await CFNX.new();
        let CFNXB = await CFNX.new();
        let USDC = await CFNX.new();
        let startTime = 10000000;
        let minePool = await fixedMinePool.new(CFNXA.address,CFNXB.address,USDC.address,startTime);
        await CFNXA.mint(accounts[0],1000000000000000);
        await CFNXA.approve(minePool.address,1000000000000000);
        await CFNXB.mint(accounts[0],1000000000000000);
        await CFNXB.approve(minePool.address,1000000000000000);
        let nowId = await minePool.getCurrentPeriodID();
        await minePool.stakeFPTA(100000);;
        await minePool.stakeFPTB(100000,0);
        let fptA = await minePool.getUserFPTABalance(accounts[0]);
        let fptB = await minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),100000,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),100000,"getUserFPTBBalance Error");
        let userPeriodId = await minePool.getUserMaxPeriodId(accounts[0]);
        assert.equal(userPeriodId.toNumber(),0,"getUserMaxPeriodId Error");
        for (var i=1;i<10;i++){
            fptA = await minePool.getUserFPTABalance(accounts[0]);
            fptB = await minePool.getUserFPTBBalance(accounts[0]);
            assert.equal(fptA.toNumber(),100000,"getUserFPTABalance Error");
            assert.equal(fptB.toNumber(),100000,"getUserFPTBBalance Error");
            await minePool.ChangeFPTBLockedPeriod(i);
            result = await minePool.getDistributionCal(accounts[0]);
            assert.equal(result[0].toNumber(),100000000,"getDistributionCal Error");
            assert.equal(result[1].toNumber(),2100000000,"getDistributionCal Error");
            result = await minePool.getFPTBFlexibleDistribution();
            assert.equal(result.toString(),"0","getFPTBFlexibleDistribution Error");
            result = await minePool.getFPTADistribution();
            assert.equal(result.toString(),"100000000","getFPTADistribution Error");
            for (var j=0;j<i;j++){
                result = await minePool.getPeriodDistribution(nowId.toNumber()+j);
                assert.equal(result.toString(),"2100000000","getPeriodDistribution Error");
                result = await minePool.getPeriodWeightDistribution(nowId.toNumber()+j);
                assert.equal(result.toNumber(),2200000000*(4+i-j)-100000000,"getPeriodWeightDistribution Error");
            }
            result = await minePool.getPeriodDistribution(nowId.toNumber()+i);
            assert.equal(result.toString(),"0","getPeriodDistribution Error");
            result = await minePool.getPeriodWeightDistribution(nowId.toNumber()+i);
            assert.equal(result.toString(),"0","getPeriodWeightDistribution Error");
            result = await minePool.getUserDistribution(accounts[0],nowId);
            assert.equal(result.toString(),"2200000000","getUserDistribution Error");
        }

    });
});