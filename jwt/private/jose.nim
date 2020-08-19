import json, strutils

import utils

type
  CryptoException* = object of Exception
  UnsupportedAlgorithm* = object of CryptoException

  SignatureAlgorithm* = enum
    NONE
    HS256
    HS384
    HS512
    RS256
    RS384
    RS512
    ES256
    ES384
    ES512

  JOSEHeader* = object
    alg*: SignatureAlgorithm
    typ*: string


proc strToSignatureAlgorithm(s: string): SignatureAlgorithm =
  try:
    result = parseEnum[SignatureAlgorithm](s)
  except ValueError:
    raise newException(UnsupportedAlgorithm, "$# isn't supported" % s)


proc toHeader*(j: JsonNode): JOSEHeader =
  # Check that the keys are present so we dont blow up.
  utils.checkKeysExists(j, "alg", "typ")

  let algStr = j["alg"].getStr()
  let algo = strToSignatureAlgorithm(algStr)

  result = JOSEHeader(
    alg: algo,
    typ: j["typ"].getStr()
  )


proc `%`*(alg: SignatureAlgorithm): JsonNode =
  let s = $alg
  return %s


proc `%`*(h: JOSEHeader): JsonNode =
  return %{
    "alg": %h.alg,
    "typ": %h.typ
  }


proc toBase64*(h: JOSEHeader): string =
  let asJson = %h
  result = encodeUrlSafe($asJson)
