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
    let fnxAmount = new BN("6");
    let fnxPerPerson = new BN("1");
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

        let tx = await colpoolInst.initialize(fptbInst.address);
        assert.equal(tx.receipt.status,true);

        tx = await minepoolInst.initialize(fptbInst.address);
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


        tx = await airdropproxyInst.setTotalAirdropFnx(web3.utils.toWei(fnxAmount));
        assert.equal(tx.receipt.status,true);

        tx = await airdropproxyInst.setFnxPerPerson(web3.utils.toWei(fnxPerPerson));
        assert.equal(tx.receipt.status,true);

        tx = await fnxInst.mint(airdropproxyInst.address,web3.utils.toWei(fnxAmount));
        assert.equal(tx.receipt.status,true);

        let i = 1;
        for(;i<7;i++) {
            tx = await airdropproxyInst.addWhiteList(accounts[i]);
            assert.equal(tx.receipt.status,true);
        }
    });

    it('6 users claim adirdrop to minepool', async function () {
        let i =1;
        for(;i<7;i++) {
            console.log("user"+i +" airdrop")
            let beforeFnxAirdropproxy = await fnxInst.balanceOf(airdropproxyInst.address);
            let beforeLockedFtpUser =  await minepoolInst.lockedBalances(accounts[i]);
            let beforeFptbMinepool = await fptbInst.balanceOf(minepoolInst.address);

            let tx = await airdropproxyInst.claim({from:accounts[i]});
            assert.equal(tx.receipt.status,true);

            let afterFnxAirdropproxy = await fnxInst.balanceOf(airdropproxyInst.address);
            let afterLockedFtpUser =  await minepoolInst.lockedBalances(accounts[i]);
            let afterFptbMinepool = await fptbInst.balanceOf(minepoolInst.address);

            let diff = web3.utils.fromWei(new BN(beforeFnxAirdropproxy)) - web3.utils.fromWei(new BN(afterFnxAirdropproxy));
            console.log("diff proxy fnx=" + diff);

            diff = web3.utils.fromWei(new BN(afterLockedFtpUser)) - web3.utils.fromWei(new BN(beforeLockedFtpUser));
            console.log("diff mine user locked fptb=" + diff);

            diff = web3.utils.fromWei(new BN(afterFptbMinepool)) - web3.utils.fromWei(new BN(beforeFptbMinepool));
            console.log("diff mine pool diff fptb=" + diff);


          }
    })


})