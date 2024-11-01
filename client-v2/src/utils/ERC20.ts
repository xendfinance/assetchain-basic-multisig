import { formatEther, formatUnits } from "ethers";
import ERC20ABI from "../abi/ERC20.json";
export class ERC20 {
    static getInstance(provider: any, contractAddress: string) {
        const instance = new provider.eth.Contract(
            ERC20ABI.abi,
            contractAddress
        );
    
      return instance;
    }

    static async balanceOf(provider: any, contractAddress: string, address: string){
        try {
            const instance = this.getInstance(provider, contractAddress)
            const [decimals, balance] = await Promise.all([
                instance.methods.decimals().call(),
                instance.methods.balanceOf(address).call()
            ])
            let bal = 0
            if (Number(decimals) >= 18){
                bal = +formatEther(balance)
            }else {
                bal = +formatUnits(balance, decimals)
            }
            return bal
        } catch (error) {
            throw error
        }
        

    }
}