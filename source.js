const ethers = await import("npm:ethers")

const estateOwnerDataRequest = Functions.makeHttpRequest({
  url: `https://estate-backend-liart.vercel.app/api/v1/user/eth/${args[0]}`,
  method: "GET",
  headers: {
    "x-api-key": secrets.apiKey
  }

})

const estateOwnerDataResponse = await estateOwnerDataRequest;

if (estateOwnerDataResponse.error) throw Error("Request failed, try checking the params provided x")

const estateOwnerData = estateOwnerDataResponse.data.data.user;
const estateCost = estateOwnerData.currentEstateCost;
const percentageToTokenize = estateOwnerData.percentageToTokenize;
const isApproved = estateOwnerData.isVerified;
const _saltBytes = estateOwnerData._id;
const _verifyingOperator = "0xVerifyingOperator";
console.log(estateCost, percentageToTokenize, isApproved, _saltBytes, _verifyingOperator);

const data = {
  param1: BigInt(estateCost),
  param2: BigInt(percentageToTokenize),
  param3: isApproved,
  param4: ('0x' + _saltBytes),
  param5: _verifyingOperator
};
console.log(data);

const encodedData = ethers.AbiCoder.defaultAbiCoder().encode(
  ["uint256", "uint256", "bool", "bytes", "address"],
  [data.param1, data.param2, data.param3, data.param4, data.param5]
);

const decodedData = ethers.AbiCoder.defaultAbiCoder().decode(
  ["uint256", "uint256", "bool", "bytes", "address"],
  encodedData
);

console.log(decodedData);

return ethers.getBytes(encodedData);