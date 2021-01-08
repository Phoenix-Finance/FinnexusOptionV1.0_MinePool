const fixedMinePool = artifacts.require("fixedMinePool_test");
const CFNX = artifacts.require("CFNX");
const BN = require("bn.js");
const {migrateTestMinePool,checkUserDistribution} = require("./testFunctions.js")
let PeriodTime = 90*86400;
contract('fixedMinePool', function (accounts){

    it('fixedMinePool set functions', async function (){
        let contracts = await migrateTestMinePool(accounts);
        let fptA = await contracts.minePool.getFPTAAddress();
        let fptB = await contracts.minePool.getFPTBAddress();
        let getTime = await contracts.minePool.getStartTime();
        let startTime = 10000000;
        assert.equal(contracts.CFNXA.address,fptA,"getFPTAAddress Error");
        assert.equal(contracts.CFNXB.address,fptB,"getFPTBAddress Error");
        assert.equal(getTime,startTime,"getFPTBAddress Error");
        let testTime = startTime + 1000;
        for (var i=1;i<100;i++){
            let periodID = await contracts.minePool.getPeriodIndex(testTime);
            assert.equal(periodID,i,"getPeriodIndex Error");
            testTime += PeriodTime;
        }
        for (var i=1;i<100;i++){
            let endTime = await contracts.minePool.getPeriodFinishTime(i);
            assert.equal(endTime.toNumber(),startTime +i*PeriodTime,"getPeriodFinishTime Error");
        }
    });
    it('fixedMinePool stake FPTA function', async function (){
        let contracts = await migrateTestMinePool(accounts);
        await contracts.minePool.stakeFPTA(100000);
        let fptA = await contracts.minePool.getUserFPTABalance(accounts[0]);
        let fptB = await contracts.minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),100000,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),0,"getUserFPTBBalance Error");
        let contractBalance = await contracts.CFNXA.balanceOf(contracts.minePool.address);
        assert.equal(contractBalance.toNumber(),100000,"getUserFPTABalance Error");
        await checkUserDistribution(contracts,accounts[0]);
        await contracts.minePool.stakeFPTA(100000);
        fptA = await contracts.minePool.getUserFPTABalance(accounts[0]);
        fptB = await contracts.minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),200000,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),0,"getUserFPTBBalance Error");
        let expired = await contracts.minePool.getUserExpired(accounts[0]);
        let curtime = Date.now()/1000+86400*15;
        assert(Math.abs(expired.toNumber()-curtime)<10,"getTotalMined error");
        contractBalance = await contracts.CFNXA.balanceOf(contracts.minePool.address);
        assert.equal(contractBalance.toNumber(),200000,"getUserFPTABalance Error");
        await checkUserDistribution(contracts,accounts[0]);
        await contracts.minePool.unstakeFPTA(100000);
        fptA = await contracts.minePool.getUserFPTABalance(accounts[0]);
        fptB = await contracts.minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),100000,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),0,"getUserFPTBBalance Error");
        contractBalance = await contracts.CFNXA.balanceOf(contracts.minePool.address);
        assert.equal(contractBalance.toNumber(),100000,"getUserFPTABalance Error");
        await checkUserDistribution(contracts,accounts[0]);
        await contracts.minePool.unstakeFPTA(100000);
        fptA = await contracts.minePool.getUserFPTABalance(accounts[0]);
        fptB = await contracts.minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),0,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),0,"getUserFPTBBalance Error");
        contractBalance = await contracts.CFNXA.balanceOf(contracts.minePool.address);
        assert.equal(contractBalance.toNumber(),0,"getUserFPTABalance Error");
        await checkUserDistribution(contracts,accounts[0]);
        await contracts.minePool.setOperator(1,accounts[1]);
        await contracts.minePool.lockAirDrop(accounts[2],1000000,{from:accounts[1]});
        contractBalance = await contracts.CFNXB.balanceOf(contracts.minePool.address);
        assert.equal(contractBalance.toNumber(),1000000,"getUserFPTABalance Error");
        fptA = await contracts.minePool.getUserFPTABalance(accounts[2]);
        assert.equal(fptA.toNumber(),0,"getUserFPTABalance Error");
        fptB = await contracts.minePool.getUserFPTBBalance(accounts[2]);
        assert.equal(fptB.toNumber(),1000000,"getUserFPTABalance Error");
        fptB = await contracts.minePool.getUserFPTBBalance(accounts[1]);
        assert.equal(fptB.toNumber(),0,"getUserFPTABalance Error");
    });
    it('fixedMinePool flexible stake FPTB function', async function (){
        let contracts = await migrateTestMinePool(accounts);
        await contracts.minePool.stakeFPTB(100000,0);
        let fptA = await contracts.minePool.getUserFPTABalance(accounts[0]);
        let fptB = await contracts.minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),0,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),100000,"getUserFPTBBalance Error");
        let contractBalance = await contracts.CFNXB.balanceOf(contracts.minePool.address);
        assert.equal(contractBalance.toNumber(),100000,"getUserFPTABalance Error");
        await checkUserDistribution(contracts,accounts[0]);
        await contracts.minePool.stakeFPTB(100000,0);
        fptA = await contracts.minePool.getUserFPTABalance(accounts[0]);
        fptB = await contracts.minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),0,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),200000,"getUserFPTBBalance Error");
        await checkUserDistribution(contracts,accounts[0]);
        await contracts.minePool.unstakeFPTB(100000);
        fptA = await contracts.minePool.getUserFPTABalance(accounts[0]);
        fptB = await contracts.minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),0,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),100000,"getUserFPTBBalance Error");
        contractBalance = await contracts.CFNXB.balanceOf(contracts.minePool.address);
        assert.equal(contractBalance.toNumber(),100000,"getUserFPTABalance Error");
        result = await contracts.minePool.getDistributionCal(accounts[0]);
        assert.equal(result.toString(),"100000000","getDistributionCal Error");
        result = await contracts.minePool.getTotalDistribution();
        assert.equal(result.toString(),"100000000","getTotalDistribution Error");
        result = await contracts.minePool.getUserDistribution(accounts[0]);
        assert.equal(result.toString(),"100000000","getUserDistribution Error");
        await contracts.minePool.unstakeFPTB(100000);
        fptA = await contracts.minePool.getUserFPTABalance(accounts[0]);
        fptB = await contracts.minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),0,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),0,"getUserFPTBBalance Error");
        contractBalance = await contracts.CFNXB.balanceOf(contracts.minePool.address);
        assert.equal(contractBalance.toNumber(),0,"getUserFPTBBalance Error");
        result = await contracts.minePool.getDistributionCal(accounts[0]);
        assert.equal(result.toString(),"0","getDistributionCal Error");
        result = await contracts.minePool.getTotalDistribution();
        assert.equal(result.toString(),"0","getTotalDistribution Error");
        result = await contracts.minePool.getUserDistribution(accounts[0]);
        assert.equal(result.toString(),"0","getUserDistribution Error");
    });
    it('fixedMinePool Locked stake FPTB function', async function (){
        let contracts = await migrateTestMinePool(accounts);
        let nowId = await contracts.minePool.getCurrentPeriodID();
        await contracts.minePool.stakeFPTB(100000,2);
        let fptA = await contracts.minePool.getUserFPTABalance(accounts[0]);
        let fptB = await contracts.minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),0,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),100000,"getUserFPTBBalance Error");
        let userPeriodId = await contracts.minePool.getUserMaxPeriodId(accounts[0]);
        assert.equal(userPeriodId.toNumber(),nowId.toNumber()+1,"getUserMaxPeriodId Error");
        let contractBalance = await contracts.CFNXB.balanceOf(contracts.minePool.address);
        assert.equal(contractBalance.toNumber(),100000,"getUserFPTABalance Error");
        await checkUserDistribution(contracts,accounts[0]);
        await contracts.minePool.stakeFPTB(100000,2);
        fptA = await contracts.minePool.getUserFPTABalance(accounts[0]);
        fptB = await contracts.minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),0,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),200000,"getUserFPTBBalance Error");
        contractBalance = await contracts.CFNXB.balanceOf(contracts.minePool.address);
        assert.equal(contractBalance.toNumber(),200000,"getUserFPTABalance Error");
        await checkUserDistribution(contracts,accounts[0]);
        await contracts.minePool.unstakeFPTB(100000);
        fptA = await contracts.minePool.getUserFPTABalance(accounts[0]);
        fptB = await contracts.minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),0,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),100000,"getUserFPTBBalance Error");
        contractBalance = await contracts.CFNXB.balanceOf(contracts.minePool.address);
        assert.equal(contractBalance.toNumber(),100000,"getUserFPTABalance Error");
        await checkUserDistribution(contracts,accounts[0]);
        await contracts.minePool.unstakeFPTB(100000);
        fptA = await contracts.minePool.getUserFPTABalance(accounts[0]);
        fptB = await contracts.minePool.getUserFPTBBalance(accounts[0]);
        assert.equal(fptA.toNumber(),0,"getUserFPTABalance Error");
        assert.equal(fptB.toNumber(),0,"getUserFPTBBalance Error");
        contractBalance = await contracts.CFNXB.balanceOf(contracts.minePool.address);
        assert.equal(contractBalance.toNumber(),0,"getUserFPTABalance Error");
        await checkUserDistribution(contracts,accounts[0]);
    });
});