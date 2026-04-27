import {setUser} from "../repositories/userRepository";
import {CallableRequest, onCall} from "firebase-functions/v2/https";
import type {Users} from "../types/index";

export const signInUser = onCall(
  {region: "southamerica-east1"},
  async (request: CallableRequest<Users>)=> {
    const {uid}= request.data;
    return getUser({
      uid: uid,
    });
  }
);
