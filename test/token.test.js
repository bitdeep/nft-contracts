const web3 = require('web3');
const {accounts, contract} = require('@openzeppelin/test-environment');
const {BN, expectRevert, time, expectEvent, constants} = require('@openzeppelin/test-helpers');
const {expect} = require('chai');
const Token = contract.fromArtifact('MockERC20');
const ctx = contract.fromArtifact('HermesHeroes');
let dev, user;
let amount;

describe('ctx', function () {
    beforeEach(async function () {
        dev = accounts[0];
        user = accounts[1];
        amount = web3.utils.toWei('150');
        this.Token = await Token.new('test', 'test', amount, {from: dev});
        this.ctx = await ctx.new(this.Token.address, {from: dev});
    });
    describe('buy', function () {
        it('buy nft', async function () {
            this.timeout(60000);
            await this.Token.approve(this.ctx.address, amount, {from: dev});
            await this.Token.approve(this.ctx.address, amount, {from: user});

            // test revert on paused
            await expectRevert(this.ctx.buy(1, {from: dev}), 'Not available yet');

            const quote = await this.ctx.quote(1);
            let balanceOfDev = await this.Token.balanceOf(dev);
            // console.log('quote', quote.toString(), web3.utils.fromWei(quote, 'ether'));
            // console.log('balanceOfDev', balanceOfDev.toString(), web3.utils.fromWei(balanceOfDev, 'ether'));
            await this.ctx.unpause({from: dev});
            await this.ctx.buy(1, {from: dev});

            // test balance transfer
            balanceOfDev = await this.Token.balanceOf(dev);
            const balanceOfCtx = await this.Token.balanceOf(this.ctx.address);
            expect(balanceOfDev).to.be.bignumber.equal(new BN(0));
            expect(balanceOfCtx).to.be.bignumber.equal(amount);

            // test minted amount
            const minted = await this.ctx.minted();
            expect(minted).to.be.bignumber.equal(new BN(1));

            // test withdraw
            await expectRevert(this.ctx.withdraw({from: user}), 'Ownable: caller is not the owner');
            await this.ctx.withdraw({from: dev});
            balanceOfDev = await this.Token.balanceOf(dev);
            expect(balanceOfDev).to.be.bignumber.equal(amount);

            const baseURI = await this.ctx.baseURI();
            const tokenURI = await this.ctx.tokenURI( new BN(1) );
            console.log('baseURI', baseURI );
            console.log('tokenURI', tokenURI);


        });
        it('revert on non balance', async function () {
            await this.ctx.unpause({from: dev});
            await this.Token.approve(this.ctx.address, amount, {from: user});
            await expectRevert(this.ctx.buy(1, {from: user}), 'IRIS balance is too low');
        });
    });

});
