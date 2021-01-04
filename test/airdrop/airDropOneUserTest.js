const { time, expectEvent} = require("@openzeppelin/test-helpers")
let utils = require('../converterTest/utils.js');

let colpool = artifacts.require("mockColPool");
let minepool = artifacts.require("mockMine");
let fptb = artifacts.require("mockToken");
let airdropvault =  artifacts.require("AirDropVault");
let airdropProxy = artifacts.require("AirDropVaultProxy");

const BN = require("bn.js");
const assert = require('assert');

const ONE_HOUR = 60*60;
const ONE_DAY = ONE_HOUR * 24;
const ONE_MONTH = 30 * ONE_DAY;

contract('TokenConverter', function (accounts) {
    let cfnxAmount1 = new BN("60000000000000000000");
    let cfnxAmount2 = new BN("120000000000000000000");
    let cfnxAmount3 = new BN("125000000000000000000");
    let fnxAmount = new BN("90000000000000000000000");

    let fptbInst;
    let fnxInst;

    let colpoolInst;
    let minepoolInst;

    let airdropVaultInst;
    let airdropproxyInst;


    before(async () => {
        fptbInst = await fptb.new();
        console.log("fptb address:" + fptbInst.address);

        colpoolInst = await colpool.new();
        console.log("colpool address:" + colpoolInst.address);

        minepoolInst = await minepool.new();
        console.log("minepool address:" + minepoolInst.address);

        fnxInst = await fptb.new();
        console.log("fnx address:" + fnxInst.address);

        let tx = await minepoolInst.initialize(fptbInst.address);
        assert.equal(tx.receipt.status,true);

        tx = await colpoolInst.initialize(fptbInst.address);
        assert.equal(tx.receipt.status,true);

        airdropVaultInst = await airdropvault.new();
        console.log("airdropvault address:" + airdropVaultInst.address);

        airdropproxyInst = await airdropProxy.new(airdropVaultInst.address);
        console.log("airdropProxy address:" + airdropproxyInst.address);

        tx = await airdropproxyInst.setOptionColPool(colpoolInst.address);
        assert.equal(tx.receipt.status,true);

        tx = await airdropproxyInst.setMinePool(minepoolInst.address);
        assert.equal(tx.receipt.status,true);

        tx = await airdropproxyInst.setFnxToken(fnxInst.address);
        assert.equal(tx.receipt.status,true);

        tx = await airdropproxyInst.setFptbToken(fptbInst.address);
        assert.equal(tx.receipt.status,true);

        tx = await airdropproxyInst.setFptbToken(fptbInst.address);
        assert.equal(tx.receipt.status,true);


    });

    it('1 User1 input CFNX and get 1/6 FNX', async function () {
        // let beforeFnxUser =  await FNXInst.balanceOf(accounts[1]);
        // let beforeCFnxBalanceUser = await CFNXInst.balanceOf(accounts[1]);
        // console.log(beforeCFnxBalanceUser);
        // console.log(await CFNXInst.allowance(accounts[1],CvntProxyInst.address));
        //
        // let beforeFnxBalanceProxy = await CFNXInst.balanceOf(CvntProxyInst.address);
        // let tx = await CvntProxyInst.inputCfnxForInstallmentPay(cfnxAmount1,{from:accounts[1]});
        // assert.equal(tx.receipt.status,true);
        //
        // let afterFnxUser =  await FNXInst.balanceOf(accounts[1]);
        // let afterCFnxBalanceUser = await CFNXInst.balanceOf(accounts[1]);
        // let afterFnxBalanceProxy = await CFNXInst.balanceOf(CvntProxyInst.address);
        //
        // let diffCFNXUser = web3.utils.fromWei(new BN(beforeCFnxBalanceUser)) - web3.utils.fromWei(new BN(afterCFnxBalanceUser));
        // console.log("CFNX diff User:" + diffCFNXUser);
        // let diffContract = web3.utils.fromWei(new BN(afterFnxBalanceProxy)) - web3.utils.fromWei(new BN(beforeFnxBalanceProxy));
        // console.log("CFNX diff contract:" + diffContract);
        // assert.equal(diffCFNXUser,diffContract);
        //
        // let diffFNXUser = web3.utils.fromWei(new BN(afterFnxUser)) - web3.utils.fromWei(new BN(beforeFnxUser));
        // console.log("FNX diff user:" + diffFNXUser);
        // assert.equal(diffFNXUser,diffContract/6);
        //
        // let lockedBalance = await CvntProxyInst.lockedBalanceOf(accounts[1]);
        // console.log(lockedBalance);
        // assert.equal(web3.utils.fromWei(lockedBalance),web3.utils.fromWei(cfnxAmount1)*5/6);
    })


})