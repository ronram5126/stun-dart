const int MAGIC_COOKIE = 0x2112A442;

const int RESERVED = 0x0000;
const int ATTRIBUTE_MAPPED_ADDRESS  = 0x0000;
const int ATTRIBUTE_RESPONSE_ADDRESS = 0x0000;
const int ATTRIBUTE_CHANGE_ADDRESS = 0x0000;
const int ATTRIBUTE_SOURCE_ADDRESS = 0x0000;
const int ATTRIBUTE_CHANGED_ADDRESS = 0x0000;
const int ATTRIBUTE_USERNAME = 0x0000;
const int ATTRIBUTE_PASSWORD  = 0x0000;
const int ATTRIBUTE_MESSAGE_INTEGRITY = 0x0000;
const int ATTRIBUTE_ERROR-CODE = 0x0000;
const int ATTRIBUTE_UNKNOWN-ATTRIBUTES   = 0x0000;
const int ATTRIBUTE_REFLECTED-FROM = 0x0000;
const int ATTRIBUTE_REALM = 0x0000;
const int ATTRIBUTE_NONCE = 0x0000;
const int ATTRIBUTE_XOR-MAPPED_ADDRESS   = 0x0000;
const int ATTRIBUTE_  Comprehension-optional range (0x8000-0xFFFF)      0x8022: SOFTWARE      0x8023: ALTERNATE-SERVER      0x8028: FINGERPRINT




eserved,
  mappedAddress,
  responseAddress,
  changeAddress,
  sourceAddress,
  changedAddress,
  username,
  password,
  messageIntegrity,
  errorCode,
  unknownAttributes,
  reflectedFrom,
  relm,
  nonce,
  xorMappedAddress,
  software,
  alternateServer,
  fingerprint
}

int getHoot (STUN_ATTRIBUTE_TYPE attrib) {
  switch(attrib) {
    case STUN_ATTRIBUTE_TYPE.mappedAddress: return 0x0001;
    case STUN_ATTRIBUTE_TYPE.responseAddress: return 0x0002;
    case STUN_ATTRIBUTE_TYPE.changeAddress: return 0x0003;
    case STUN_ATTRIBUTE_TYPE.sourceAddress: return 0x0004;
    case STUN_ATTRIBUTE_TYPE.changedAddress: return 0x0005;
    case STUN_ATTRIBUTE_TYPE.username: return 0x0006;
    case STUN_ATTRIBUTE_TYPE.password: return 0x0007;
    case STUN_ATTRIBUTE_TYPE.messageIntegrity: return 0x0008;
    case STUN_ATTRIBUTE_TYPE.errorCode: return 0x0009;
    case STUN_ATTRIBUTE_TYPE.unknownAttributes: return 0x000A;
    case STUN_ATTRIBUTE_TYPE.reflectedFrom: return 0x000B;
    case STUN_ATTRIBUTE_TYPE.relm: return 0x0014;
    case STUN_ATTRIBUTE_TYPE.nonce: return 0x0015;
    case STUN_ATTRIBUTE_TYPE.xorMappedAddress: return 0x0020;
    case STUN_ATTRIBUTE_TYPE.software: return 0x8022;
    case STUN_ATTRIBUTE_TYPE.alternateServer: return 0x8023;
    case STUN_ATTRIBUTE_TYPE.fingerprint: return 0x8028;
    default: return 0x0000;
  }
}
 