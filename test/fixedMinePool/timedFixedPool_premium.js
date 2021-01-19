const fixedMinePool = artifacts.require("fixedMinePool_Timed");
const CFNX = artifacts.require("CFNX");
const BN = require("bn.js");
let PeriodTime = 90*86400;
contract('fixedMinePool_Timed', function (accounts){
    it('fixedMinePool_Timed one person Premium', async function (){
        let CFNXA = await CFNX.new();
        let CFNXB = await CFNX.new();
        let USDC = await CFNX.new();
        let startTime = 10000000;
        let minePool = await fixedMinePool.new(CFNXA.address,CFNXB.address,startTime);
        minePool.setOperator(0,accounts[0]);
        await CFNXA.mint(accounts[0],1000000000000000);
        await CFNXA.approve(minePool.address,1000000000000000);
        await USDC.mint(accounts[0],1000000000000000);
        await USDC.approve(minePool.address,1000000000000000);
        await CFNXA.mint(minePool.address,1000000000000000);
        await CFNXB.mint(accounts[0],1000000000000000);
        await CFNXB.approve(minePool.address,1000000000000000);
        let nowId = await minePool.getCurrentPeriodID();
        assert.equal(nowId.toNumber(),1,"getCurrentPeriodID Error");
        await minePool.stakeFPTA(100000);
        await minePool.stakeFPTB(100000,7);
        await minePool.setMineCoinInfo(CFNXA.address,2000000,1);
        await minePool.setTime(10);
        await minePool.distributePremium(USDC.address,1,10000);
        mineBalance = await minePool.getUserLatestPremium(accounts[0],USDC.address);
        realMine = 10000;
        console.log(mineBalance.toNumber(),realMine);
        assert(Math.abs(mineBalance.toNumber()-realMine)<10,"getUserLatestPremium error");
        await minePool.setTime(20);
        await minePool.distributePremium(USDC.address,2,10000);
        mineBalance = await minePool.getUserLatestPremium(accounts[0],USDC.address);
        realMine = 20000;
        assert(Math.abs(mineBalance.toNumber()-realMine)<10,"getUserLatestPremium error");
        await minePool.setTime(55);
        await minePool.distributePremium(USDC.address,4,10000);
        mineBalance = await minePool.getUserLatestPremium(accounts[0],USDC.address);
        realMine = 30000;
        assert(Math.abs(mineBalance.toNumber()-realMine)<10,"getUserLatestPremium error");
        let Balance0 = await USDC.balanceOf(minePool.address); 
        await minePool.redeemPremiumCoin(USDC.address,mineBalance);
        let Balance1 = await USDC.balanceOf(minePool.address); 
        assert.equal(mineBalance.toNumber(),Balance0.toNumber()-Balance1.toNumber(),"redeemPremium error");
        await minePool.distributePremium(USDC.address,3,10000);
        mineBalance = await minePool.getUserLatestPremium(accounts[0],USDC.address);
        realMine = 10000;
        assert(Math.abs(mineBalance.toNumber()-realMine)<10,"getUserLatestPremium error");
        await minePool.redeemPremium();
        mineBalance = await minePool.getUserLatestPremium(accounts[0],USDC.address);
        assert.equal(mineBalance.toNumber(),0,"getMinerBalance error");
    });

    it('fixedMinePool_Timed one person Premium 2', async function (){
        let CFNXA = await CFNX.new();
        let CFNXB = await CFNX.new();
        let USDC = await CFNX.new();
        let startTime = 10000000;
        let minePool = await fixedMinePool.new(CFNXA.address,CFNXB.address,startTime);
        minePool.setOperator(0,accounts[0]);
        await CFNXA.mint(accounts[0],1000000000000000);
        await CFNXA.approve(minePool.address,1000000000000000);
        await USDC.mint(accounts[0],1000000000000000);
        await USDC.approve(minePool.address,1000000000000000);
        await CFNXA.mint(minePool.address,1000000000000000);
        await CFNXB.mint(accounts[0],1000000000000000);
        await CFNXB.approve(minePool.address,1000000000000000);
        let nowId = await minePool.getCurrentPeriodID();
        assert.equal(nowId.toNumber(),1,"getCurrentPeriodID Error");
        await minePool.stakeFPTA(100000);
        await minePool.stakeFPTB(100000,2);
        await minePool.setMineCoinInfo(CFNXA.address,2000000,1);
        await minePool.setTime(10);
        await minePool.distributePremium(USDC.address,1,10000);

        mineBalance = await minePool.getUserLatestPremium(accounts[0],USDC.address);
        realMine = 10000;
        assert(Math.abs(mineBalance.toNumber()-realMine)<10,"getUserLatestPremium error");
        await minePool.setTime(20);
        await minePool.distributePremium(USDC.address,2,10000);
        mineBalance = await minePool.getUserLatestPremium(accounts[0],USDC.address);
        assert(Math.abs(mineBalance.toNumber()-realMine)<10,"getUserLatestPremium error");
        await minePool.setTime(55);
        await minePool.distributePremium(USDC.address,4,10000);
        mineBalance = await minePool.getUserLatestPremium(accounts[0],USDC.address);
        assert(Math.abs(mineBalance.toNumber()-realMine)<10,"getUserLatestPremium error");
        bErr = false;
        try {
            await minePool.redeemPremiumCoin(USDC.address,15000);    
        } catch (error) {
            bErr = true;
        }
        assert(bErr,"redeemPremium error");
        let Balance0 = await USDC.balanceOf(minePool.address); 
        await minePool.redeemPremiumCoin(USDC.address,5000);
        let Balance1 = await USDC.balanceOf(minePool.address); 
        assert.equal(mineBalance.toNumber()-5000,Balance0.toNumber()-Balance1.toNumber(),"redeemPremium error");
        await minePool.distributePremium(USDC.address,3,10000);
        mineBalance = await minePool.getUserLatestPremium(accounts[0],USDC.address);
        assert(Math.abs(mineBalance.toNumber()-5000)<10,"getUserLatestPremium error");
    });
    it('fixedMinePool_Timed two persons Premium', async function (){
        let CFNXA = await CFNX.new();
        let CFNXB = await CFNX.new();
        let USDC = await CFNX.new();
        let startTime = 10000000;
        let minePool = await fixedMinePool.new(CFNXA.address,CFNXB.address,startTime);
        minePool.setOperator(0,accounts[0]);
        await CFNXA.mint(accounts[0],1000000000000000);
        await CFNXA.approve(minePool.address,1000000000000000);
        await USDC.mint(accounts[0],1000000000000000);
        await USDC.approve(minePool.address,1000000000000000);
        await CFNXA.mint(minePool.address,1000000000000000);
        await CFNXB.mint(accounts[0],1000000000000000);
        await CFNXB.approve(minePool.address,1000000000000000);
        await CFNXA.mint(accounts[1],1000000000000000,);
        await CFNXA.approve(minePool.address,1000000000000000,{from:accounts[1]});
        await CFNXB.mint(accounts[1],1000000000000000);
        await CFNXB.approve(minePool.address,1000000000000000,{from:accounts[1]});
        let nowId = await minePool.getCurrentPeriodID();
        assert.equal(nowId.toNumber(),1,"getCurrentPeriodID Error");
        await minePool.stakeFPTA(100000);
        await minePool.stakeFPTB(100000,4);
        await minePool.setMineCoinInfo(CFNXA.address,2000000,1);
        await minePool.setTime(10);
        await minePool.distributePremium(USDC.address,1,10000);
        mineBalance = await minePool.getUserLatestPremium(accounts[0],USDC.address);
        realMine = 10000;
        assert(Math.abs(mineBalance.toNumber()-realMine)<10,"getUserLatestPremium error");
        await minePool.setTime(15);
        await minePool.stakeFPTA(100000,{from:accounts[1]});
        await minePool.stakeFPTB(100000,6,{from:accounts[1]});
        await minePool.setTime(25);
        await minePool.distributePremium(USDC.address,2,30000);
        mineBalance = await minePool.getUserLatestPremium(accounts[0],USDC.address);
        realMine = 30000;
        assert(Math.abs(mineBalance.toNumber()-realMine)<10,"getUserLatestPremium error");
        mineBalance = await minePool.getUserLatestPremium(accounts[1],USDC.address);
        realMine = 10000;
        assert(Math.abs(mineBalance.toNumber()-realMine)<10,"getUserLatestPremium error");
        await minePool.setTime(45);
        await minePool.distributePremium(USDC.address,3,20000);
        mineBalance = await minePool.getUserLatestPremium(accounts[0],USDC.address);
        realMine = 40000;
        assert(Math.abs(mineBalance.toNumber()-realMine)<10,"getUserLatestPremium error");
        mineBalance = await minePool.getUserLatestPremium(accounts[1],USDC.address);
        realMine = 20000;
        assert(Math.abs(mineBalance.toNumber()-realMine)<10,"getUserLatestPremium error");

        let Balance0 = await USDC.balanceOf(minePool.address); 
        await minePool.redeemPremium({from:accounts[1]});
        let Balance1 = await USDC.balanceOf(minePool.address); 
        assert.equal(mineBalance.toNumber(),Balance0.toNumber()-Balance1.toNumber(),"redeemPremium error");
        await minePool.distributePremium(USDC.address,4,10000);
        mineBalance = await minePool.getUserLatestPremium(accounts[0],USDC.address);
        realMine = 40000;
        assert(Math.abs(mineBalance.toNumber()-realMine)<10,"getUserLatestPremium error");
        mineBalance = await minePool.getUserLatestPremium(accounts[1],USDC.address);
        realMine = 10000;
        assert(Math.abs(mineBalance.toNumber()-realMine)<10,"getUserLatestPremium error");
        await minePool.setTime(55);
        await minePool.distributePremium(USDC.address,5,10000);
        mineBalance = await minePool.getUserLatestPremium(accounts[0],USDC.address);
        realMine = 40000;
        assert(Math.abs(mineBalance.toNumber()-realMine)<10,"getUserLatestPremium error");
        mineBalance = await minePool.getUserLatestPremium(accounts[1],USDC.address);
        realMine = 20000;
        assert(Math.abs(mineBalance.toNumber()-realMine)<10,"getUserLatestPremium error");

    });
});