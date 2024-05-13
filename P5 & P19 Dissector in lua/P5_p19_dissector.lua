nfapi_protocol = Proto("nFAPI1",  "nFAPI Protocol")

segment_length 			= ProtoField.uint16("nFAPI.segment_length", 			"segmentLength", 		base.DEC)
more_Flag_Segment_Number= ProtoField.uint8("nFAPI.more_Flag_Segment_Number", "moreFlagSegmentNumber",base.DEC)
sequence_Number    		= ProtoField.uint8("nFAPI.sequence_Number", 			"sequenceNumber", 		base.DEC)
transmit_Timestamp      = ProtoField.uint32("nFAPI.transmit_Timestamp", 		"transmitTimestamp", 	base.DEC)

sru_Termination_Type = ProtoField.uint8("nFAPI.sru_Termination_Type", "sruTerminationType", base.DEC)
phy_Id = ProtoField.uint8("nFAPI.phy_Id", "phyId", base.DEC)
msg_Type = ProtoField.uint16("nFAPI.msg_Type", "msgType", base.DEC)
message_length = ProtoField.uint32("nFAPI.message_length", "messageLength", base.DEC)

version_info = ProtoField.uint32("nFAPI.version_info", "versionInfo", base.DEC)
error_code = ProtoField.uint8("nFAPI.error_code", "errorCode", base.DEC)
num_tlv = ProtoField.uint8("nFAPI.num_tlv", "numTLV", base.DEC)

tag_16 = ProtoField.uint16("nFAPI.tag_16", "TAG", base.DEC)
length_16 = ProtoField.uint16("nFAPI.length_16", "LENGTH", base.DEC)

nfapi_sunc_mode = ProtoField.uint8("nFAPI.nfapi_sunc_mode", "nFAPISyncMode", base.DEC)
location_mode = ProtoField.uint8("nFAPI.location_mode", "locationMode", base.DEC)
location_coordinate = ProtoField.uint8("nFAPI.location_coordinate", "locationCoordinate", base.DEC)
maximum_number_phy = ProtoField.uint16("nFAPI.maximum_number_phy", "maximumNumberPHY", base.DEC)
org_unique_ident = ProtoField.uint8("nFAPI.org_unique_ident", "orgUniqueIdent", base.DEC)
number_rf_instances = ProtoField.uint16("nFAPI.number_rf_instances", "numberRfInstances", base.DEC)
number_dfe_instances = ProtoField.uint16("nFAPI.number_dfe_instances", "numberDfeInstances", base.DEC)

nfapi_protocol.fields = { 	segment_length, 
							more_Flag_Segment_Number, 
							sequence_Number, 
							transmit_Timestamp, 
							message_length,
							sru_Termination_Type,
							phy_Id,
							msg_Type,
							version_info,
							error_code,
							num_tlv,
							tag_16,
							nfapi_sunc_mode,
							location_mode,
							location_coordinate,
							maximum_number_phy,
							org_unique_ident,
							number_rf_instances,
							number_dfe_instances
						}

-- Function to convert a 16-bit integer from host byte order to network byte order (big-endian)
function htons(hostshort)
    -- Extract the two bytes from the 16-bit integer
    local byte1 = hostshort % 256
    local byte2 = math.floor(hostshort / 256) % 256
    
    -- Swap the bytes to convert to network byte order
    return byte1 * 256 + byte2
end

-- Function to convert a 32-bit integer from host byte order to network byte order (big-endian)
function htonl(hostlong)
    -- Extract the four bytes from the 32-bit integer
    local byte1 = hostlong % 256
    local byte2 = math.floor(hostlong / 256) % 256
    local byte3 = math.floor(hostlong / 65536) % 256
    local byte4 = math.floor(hostlong / 16777216) % 256
    
    -- Swap the bytes to convert to network byte order
    return byte1 * 16777216 + byte2 * 65536 + byte3 * 256 + byte4
end

function get_opcode_name(opcode)
	local opcode_name = "Unknown"

    if 	   opcode ==  265 then opcode_name = "P5_NFAPI_PNF_READY_INDICATION"
	elseif opcode ==  256 then opcode_name = "P5_NFAPI_PNF_PARAM_REQUEST"
	elseif opcode ==  257 then opcode_name = "P5_NFAPI_PNF_PARAM_RESPONSE"
	elseif opcode ==  258 then opcode_name = "P5_NFAPI_PNF_CONFIG_REQUEST"
	elseif opcode ==  259 then opcode_name = "P5_NFAPI_PNF_CONFIG_RESPONSE"
	elseif opcode ==  260 then opcode_name = "P5_NFAPI_PNF_START_REQUEST"
	elseif opcode ==  261 then opcode_name = "P5_NFAPI_PNF_START_RESPONSE"
	elseif opcode ==  262 then opcode_name = "P5_NFAPI_PNF_STOP_REQUEST"
	elseif opcode ==  263 then opcode_name = "P5_NFAPI_PNF_STOP_RESPONSE"
	elseif opcode ==  264 then opcode_name = "P5_NFAPI_START_RESPONSE"
	elseif opcode ==    0 then opcode_name = "EP5_MSG_TYPE_PARAM_REQUEST"
	elseif opcode ==    1 then opcode_name = "EP5_MSG_TYPE_PARAM_RESPONSE"
	elseif opcode ==    2 then opcode_name = "EP5_MSG_TYPE_CONFIG_REQUEST"
	elseif opcode ==    3 then opcode_name = "EP5_MSG_TYPE_CONFIG_RESPONSE"
	elseif opcode ==    4 then opcode_name = "EP5_MSG_TYPE_START_REQUEST"
	elseif opcode ==    5 then opcode_name = "EP5_MSG_TYPE_STOP_REQUEST"
	elseif opcode ==    6 then opcode_name = "EP5_MSG_TYPE_STOP_INDICATION"
	elseif opcode ==    7 then opcode_name = "EP5_MSG_TYPE_ERROR_INDICATION"
	elseif opcode ==    8 then opcode_name = "EP5_MSG_TYPE_RESET_REQUEST"
	elseif opcode ==    9 then opcode_name = "EP5_MSG_TYPE_RESET_INDICATION"
	elseif opcode == 1024 then opcode_name = "P19_NFAPI_RF_PARAM_REQUEST"
	elseif opcode == 1025 then opcode_name = "P19_NFAPI_RF_PARAM_RESPONSE"
	elseif opcode == 1026 then opcode_name = "P19_NFAPI_RF_CONFIG_REQUEST"
	elseif opcode == 1027 then opcode_name = "P19_NFAPI_RF_CONFIG_RESPONSE"
	elseif opcode == 1031 then opcode_name = "P19_NFAPI_RF_START_REQUEST"
	elseif opcode == 1032 then opcode_name = "P19_NFAPI_RF_START_RESPONSE"
	end

  return opcode_name
end

function parse_p5_param_resp_tlv(payloadSubtree, buffer, i, bufIdx)
	local name = "tlv[" .. i .. "]"
	local payloadSubtree1 = payloadSubtree:add(nfapi_protocol, buffer(), name)
	
	payloadSubtree1:add("TAG : ", buffer(bufIdx, 2):uint())
	payloadSubtree1:add("LENGTH : ", buffer(bufIdx + 2, 2):uint())
	
	local tlv_value = payloadSubtree1:add(nfapi_protocol, buffer(), "VALUE")
	
	tlv_value:add("nFAPISyncMode : ", buffer(bufIdx + 4, 1):uint())
	tlv_value:add("locationMode : ", buffer(bufIdx + 5, 1):uint())
	
	local gps = tlv_value:add(nfapi_protocol, buffer(), "locationCoordinates - 16Bytes")
	for idx = 0, 15, 1 do
		gps:add("value["..idx.."] ", buffer(bufIdx + 6 + idx, 1):uint())
	end
	
	tlv_value:add("maximumNumberPHY : ", buffer(bufIdx + 22, 2):uint())
	
	local out = tlv_value:add(nfapi_protocol, buffer(), "orgUniqueIdent -  3Bytes")
	for idx = 0, 2, 1 do
		out:add("value["..idx.."] ", buffer(bufIdx + 24 + idx, 1):uint())
	end
	
	tlv_value:add("numberRFInstances : ", buffer(bufIdx + 27, 2):uint())
	tlv_value:add("numberDFEInstances : ", buffer(bufIdx + 29, 2):uint())
end

function parse_trans_param_config_tlv(payloadSubtree2, buffer, bufIdx, tag, leng)
	if tag == 0x1001 then
		payloadSubtree2:add("dlBandwidth: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1002 then
		payloadSubtree2:add("dlFrequency: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1003 then
		payloadSubtree2:add("dlk0: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1004 then
		payloadSubtree2:add("dlGridSize: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1005 then
		payloadSubtree2:add("numTxAnt: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1006 then
		payloadSubtree2:add("uplinkBandwidth: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1007 then
		payloadSubtree2:add("uplinkFrequency: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1008 then
		payloadSubtree2:add("ulk0: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1009 then
		payloadSubtree2:add("ulGridSize: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x100A then
		payloadSubtree2:add("numRxAnt: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x100B then
		payloadSubtree2:add("FrequencyShift7p5KHz: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x100C then
		payloadSubtree2:add("phyCellId: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x100D then
		payloadSubtree2:add("FrameDuplexType: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x100E then
		payloadSubtree2:add("ssPbchPower: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x100F then
		payloadSubtree2:add("BchPayload: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1010 then
		payloadSubtree2:add("ScsCommon: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1011 then
		payloadSubtree2:add("prachSequenceLength: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1012 then
		payloadSubtree2:add("prachSubCSpacing: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1013 then
		payloadSubtree2:add("restrictedSetConfig: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1014 then
		payloadSubtree2:add("numPrachFdOccasions: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1015 then
		payloadSubtree2:add("prachRootSequenceIndex: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1016 then
		payloadSubtree2:add("numRootSequences: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1017 then
		payloadSubtree2:add("k1: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1018 then
		payloadSubtree2:add("prachZeroCorrConf: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1019 then
		payloadSubtree2:add("numUnusedRootSequences: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x101A then
		payloadSubtree2:add("unusedRootSequences: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x101B then
		payloadSubtree2:add("SsbPerRach: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x101C then
		payloadSubtree2:add("prachMultipleCarriersInABand: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x101D then
		payloadSubtree2:add("SsbOffsetPointA: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x101E then
		payloadSubtree2:add("betaPss: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x101F then
		payloadSubtree2:add("SsbPeriod: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1020 then
		payloadSubtree2:add("SsbSubcarrierOffset: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1021 then
		payloadSubtree2:add("MIB: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1022 then
		payloadSubtree2:add("SsbMask: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1023 then
		payloadSubtree2:add("BeamId_64: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1024 then
		payloadSubtree2:add("ssPbchMultipleCarriersInABand: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1025 then
		payloadSubtree2:add("multipleCellsSsPbchInACarrier: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1026 then
		payloadSubtree2:add("TddPeriod: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1027 then
		payloadSubtree2:add("SlotConfig: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x1028 then
		payloadSubtree2:add("RssiMeasurement: ", buffer(bufIdx, leng):le_uint())
	end
end

function parse_trans_param_tlv_value(payloadSubtree1, buffer, bufIdx, tag, leng)
	if tag == 0x0001 then 
		payloadSubtree1:add("ReleaseCapability : ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x0002 then 
		payloadSubtree1:add("PhyState : ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x0003 then 
		payloadSubtree1:add("Skip_blank_DL_CONFIG : ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x0004 then 
		payloadSubtree1:add("Skip_blank_UL_CONFIG : ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x0005 then 
		payloadSubtree1:add("NumConfigTLVsToReport : ", buffer(bufIdx, 2):le_uint())
		local num = buffer(bufIdx, 2):le_uint()
		local index = 2
		for i = 0, num - 1, 1 do
			local name = "tlv[" .. i .. "]"
			local payloadSubtree2 = payloadSubtree1:add(nfapi_protocol, buffer(), name)
			payloadSubtree2:add("Tag : ", buffer(bufIdx + index, 2):le_uint())
			local tag1 = buffer(bufIdx + index, 2):le_uint()
			index = index + 2
			payloadSubtree2:add("Length : ", buffer(bufIdx + index, 1):le_uint())
			local len1 = buffer(bufIdx + index, 1):le_uint()
			index = index + 1
			parse_trans_param_config_tlv(payloadSubtree2, buffer, bufIdx + index, tag1, len1)
			index = index +  len1
		end
		return index
	elseif tag == 0x0006 then 
		payloadSubtree1:add("cyclicPrefix : ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x0007 then 
		payloadSubtree1:add("supportedSubcarrierSpacingsDl : ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x0008 then 
		payloadSubtree1:add("supportedBandwidthDl : ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x0009 then 
		payloadSubtree1:add("supportedSubcarrierSpacingsUl : ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x000A then 
		payloadSubtree1:add("supportedBandwidthUl : ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x000B then 
		payloadSubtree1:add("cceMappingType : ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x000C then 
		payloadSubtree1:add("coresetOutsideFirst3OfdmSymsOfSlot : ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x000D then 
        payloadSubtree1:add("Precoder Granularity Coreset: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x000E then 
        payloadSubtree1:add("PDCCH Mu-MIMO: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x000F then 
        payloadSubtree1:add("PDCCH Precoder Cycling: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0010 then 
        payloadSubtree1:add("Max PDCCHs Per Slot: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0011 then 
        payloadSubtree1:add("PUCCH Formats: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0012 then 
        payloadSubtree1:add("Max PUCCHs Per Slot: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0013 then 
        payloadSubtree1:add("PDSCH Mapping Type: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0014 then 
        payloadSubtree1:add("PDSCH Allocation Types: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0015 then 
        payloadSubtree1:add("PDSCH VRB to PRB Mapping: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0016 then 
        payloadSubtree1:add("PDSCH CBG: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0017 then 
        payloadSubtree1:add("PDSCH DMRS Config Types: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0018 then 
        payloadSubtree1:add("PDSCH DMRS Max Length: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0019 then 
        payloadSubtree1:add("PDSCH DMRS Additional Position: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x001A then 
        payloadSubtree1:add("Max PDSCHs TBs Per Slot: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x001B then 
        payloadSubtree1:add("Max Number MIMO Layers PDSCH: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x001C then 
        payloadSubtree1:add("Supported Max Modulation Order DL: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x001D then 
        payloadSubtree1:add("Max Mu-MIMO Users DL: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x001E then 
        payloadSubtree1:add("PDSCH Data in DMRS Symbols: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x001F then 
        payloadSubtree1:add("Premption Support: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0020 then 
        payloadSubtree1:add("PDSCH Non-Slot Support: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0021 then 
        payloadSubtree1:add("UCI Mux ULSCH in PUSCH: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0022 then 
        payloadSubtree1:add("UCI Only PUSCH: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0023 then 
        payloadSubtree1:add("PUSCH Frequency Hopping: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0024 then 
        payloadSubtree1:add("PUSCH DMRS Config Types: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0025 then 
        payloadSubtree1:add("PUSCH DMRS Max Length: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0026 then 
        payloadSubtree1:add("PUSCH DMRS Additional Position: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0027 then 
        payloadSubtree1:add("PUSCH CBG: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0028 then 
        payloadSubtree1:add("PUSCH Mapping Type: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x0029 then 
        payloadSubtree1:add("PUSCH Allocation Types: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x002A then 
        payloadSubtree1:add("PUSCH VRB to PRB Mapping: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x002B then 
        payloadSubtree1:add("PUSCH Max PTRS Ports: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x002C then 
        payloadSubtree1:add("Max PDUSCHs TBs Per Slot: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x002D then 
        payloadSubtree1:add("Max Number MIMO Layers Non-CB PUSCH: ", buffer(bufIdx, leng):le_uint())
    elseif tag == 0x002E then
        payloadSubtree1:add("Supported Modulation Order UL: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x002F then 
		payloadSubtree1:add("Max Mu-MIMO Users UL: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x0030 then 
		payloadSubtree1:add("DFTS OFDM Support: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x0031 then 
		payloadSubtree1:add("PUSCH Aggregation Factor: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x0032 then 
		payloadSubtree1:add("PRACH Long Formats: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x0033 then 
		payloadSubtree1:add("PRACH Short Formats: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x0034 then 
		payloadSubtree1:add("PRACH Restricted Sets: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x0035 then 
		payloadSubtree1:add("Max PRACH FD Occasions in a Slot: ", buffer(bufIdx, leng):le_uint())
	elseif tag == 0x0036 then 
		payloadSubtree1:add("RSSI Measurement Support: ", buffer(bufIdx, leng):le_uint())
	end
	return leng
end

function parse_tras_param_resp(payloadSubtree, buffer, i, bufIdx)
	local length = 0
	local name = "tlv[" .. i .. "]"
	local payloadSubtree1 = payloadSubtree:add(nfapi_protocol, buffer(), name)
	
	payloadSubtree1:add("TAG : ", buffer(bufIdx + length, 2):uint())
	local tag = buffer(bufIdx + length, 2):uint()
	length = length + 2
	
	payloadSubtree1:add("LENGTH : ", buffer(bufIdx + length, 2):uint())
	local leng = buffer(bufIdx + length, 2):uint()
	length = length + 2
	
	if tag == 4096 then 
		payloadSubtree1:add("NFAPI_PNF_PARAM_GENERAL_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 256 then 
		payloadSubtree1:add("NFAPI_P7_VNF_ADDRESS_IPV4_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 257 then 
		payloadSubtree1:add("NFAPI_P7_VNF_ADDRESS_IPV6_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 258 then 
		payloadSubtree1:add("NFAPI_P7_VNF_PORT_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 259 then 
		payloadSubtree1:add("NFAPI_P7_PNF_ADDRESS_IPV4_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 260 then 
		payloadSubtree1:add("NFAPI_P7_PNF_ADDRESS_IPV6_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 261 then 
		payloadSubtree1:add("NFAPI_P7_PNF_PORT_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 262 then 
		payloadSubtree1:add("NFAPI_DL_TTI_TIMING_OFFSET_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 263 then 
		payloadSubtree1:add("NFAPI_UL_TTI_TIMING_OFFSET_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 264 then 
		payloadSubtree1:add("NFAPI_UL_DCI_TIMING_OFFSET_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 265 then 
		payloadSubtree1:add("NFAPI_TX_DATA_TIMING_OFFSET_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 286 then 
		payloadSubtree1:add("NFAPI_TIMING_WINDOW_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 287 then 
		payloadSubtree1:add("NFAPI_TIMING_INFO_MODE_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 288 then 
		payloadSubtree1:add("NFAPI_TIMING_INFO_PERIOD_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 289 then 
		payloadSubtree1:add("NFAPI_P7_IP_FRAGMENTATION_ALLOWED_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 290 then 
		payloadSubtree1:add("NFAPI_P7_TRANSPORT_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 291 then 
		payloadSubtree1:add("NFAPI_P7_PNF_ETHERNET_ADDRESS_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 292 then 
		payloadSubtree1:add("NFAPI_P7_VNF_ETHERNET_ADDRESS_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 293 then 
		payloadSubtree1:add("NFAPI_ECPRI_MESSAGE_TYPE_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 294 then 
		payloadSubtree1:add("NFAPI_ECPRI_PHY_TRANSPORT_ID_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 295 then 
		payloadSubtree1:add("NFAPI_P7_VERSION_USED: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 3840 then
		local fapiParam = payloadSubtree1:add(nfapi_protocol, buffer(), "FAPI_MSG_BODY")
		fapiParam:add("ERROR CODE: ", buffer(bufIdx + length, 1):le_uint())
		length = length + 1
		fapiParam:add("numTlv: ", buffer(bufIdx + length, 1):le_uint())
		local num =  buffer(bufIdx + length, 1):le_uint()
		length = length + 1
		for i = 0, num - 1, 1 do
			local fapiParamTlv = fapiParam:add(nfapi_protocol, buffer(), "TLV["..i.."]")
			fapiParamTlv:add("TAG : ", buffer(bufIdx + length, 2):le_uint())
			local tag1 = buffer(bufIdx + length, 2):le_uint()
			length = length + 2
			
			fapiParamTlv:add("LENGTH : ", buffer(bufIdx + length, 2):le_uint())
			local leng1 = buffer(bufIdx + length, 2):le_uint()
			length = length + 2
			leng1 = parse_trans_param_tlv_value(fapiParamTlv, buffer, bufIdx + length, tag1, leng1)
			length = length + leng1
		end		
	end
	length = length + leng
	return length
end

function parse_trans_config_tlv_value(payloadSubtree2, buffer, bufIdx, tag, leng)
	if tag == 0x1001 then
		payloadSubtree2:add("dlBandwidth: ", buffer(bufIdx, 2):le_uint())
	elseif tag == 0x1002 then
		payloadSubtree2:add("dlFrequency: ", buffer(bufIdx, 4):le_uint())
	elseif tag == 0x1003 then
		local dlk0_values = {}
		for i = 0, 4 do
			dlk0_values[i] = buffer(bufIdx + i * 2, 2):le_uint()
		end
		payloadSubtree2:add("dlk0: ", table.concat(dlk0_values, ", "))
	elseif tag == 0x1004 then
		local dlGridSize_values = {}
		for i = 0, 4 do
			dlGridSize_values[i] = buffer(bufIdx + i * 2, 2):le_uint()
		end
		payloadSubtree2:add("dlGridSize: ", table.concat(dlGridSize_values, ", "))
	elseif tag == 0x1005 then
		payloadSubtree2:add("numTxAnt: ", buffer(bufIdx, 2):le_uint())
	elseif tag == 0x1006 then
		payloadSubtree2:add("uplinkBandwidth: ", buffer(bufIdx, 2):le_uint())
	elseif tag == 0x1007 then
		payloadSubtree2:add("uplinkFrequency: ", buffer(bufIdx, 4):le_uint())
	elseif tag == 0x1008 then
		local ulk0_values = {}
		for i = 0, 4 do
			ulk0_values[i] = buffer(bufIdx + i * 2, 2):le_uint()
		end
		payloadSubtree2:add("ulk0: ", table.concat(ulk0_values, ", "))
	elseif tag == 0x1009 then
		local ulGridSize_values = {}
		for i = 0, 4 do
			ulGridSize_values[i] = buffer(bufIdx + i * 2, 2):le_uint()
		end
		payloadSubtree2:add("ulGridSize: ", table.concat(ulGridSize_values, ", "))
	elseif tag == 0x100A then
		payloadSubtree2:add("numRxAnt: ", buffer(bufIdx, 2):le_uint())
	elseif tag == 0x100B then
		payloadSubtree2:add("FrequencyShift7p5KHz: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x100C then
		payloadSubtree2:add("phyCellId: ", buffer(bufIdx, 2):le_uint())
	elseif tag == 0x100D then
		payloadSubtree2:add("FrameDuplexType: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x100E then
		payloadSubtree2:add("ssPbchPower: ", buffer(bufIdx, 4):le_uint())
	elseif tag == 0x100F then
		payloadSubtree2:add("BchPayload: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x1010 then
		payloadSubtree2:add("ScsCommon: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x1011 then
		payloadSubtree2:add("prachSequenceLength: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x1012 then
		payloadSubtree2:add("prachSubCSpacing: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x1013 then
		payloadSubtree2:add("restrictedSetConfig: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x1014 then
		payloadSubtree2:add("numPrachFdOccasions: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x1015 then
		payloadSubtree2:add("prachRootSequenceIndex: ", buffer(bufIdx, 2):le_uint())
	elseif tag == 0x1016 then
		payloadSubtree2:add("numRootSequences: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x1017 then
		payloadSubtree2:add("k1: ", buffer(bufIdx, 2):le_uint())
	elseif tag == 0x1018 then
		payloadSubtree2:add("prachZeroCorrConf: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x1019 then
		payloadSubtree2:add("numUnusedRootSequences: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x101A then
		payloadSubtree2:add("unusedRootSequences: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x101B then
		payloadSubtree2:add("SsbPerRach: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x101C then
		payloadSubtree2:add("prachMultipleCarriersInABand: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x101D then
		payloadSubtree2:add("SsbOffsetPointA: ", buffer(bufIdx, 2):le_uint())
	elseif tag == 0x101E then
		payloadSubtree2:add("betaPss: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x101F then
		payloadSubtree2:add("SsbPeriod: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x1020 then
		payloadSubtree2:add("SsbSubcarrierOffset: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x1021 then
		payloadSubtree2:add("MIB: ", buffer(bufIdx, 4):le_uint())
	elseif tag == 0x1022 then
		payloadSubtree2:add("SsbMask: ", buffer(bufIdx, 4):le_uint())
	elseif tag == 0x1023 then
		payloadSubtree2:add("BeamId_64: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x1024 then
		payloadSubtree2:add("ssPbchMultipleCarriersInABand: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x1025 then
		payloadSubtree2:add("multipleCellsSsPbchInACarrier: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x1026 then
		payloadSubtree2:add("TddPeriod: ", buffer(bufIdx, 1):le_uint())
	elseif tag == 0x1027 then
		local ulk0_values = {}
		for i = 0, 4 do
			ulk0_values[i] = buffer(bufIdx + i, 1):le_uint()
		end
		payloadSubtree2:add("SlotConfig: ", table.concat(ulk0_values, ", "))
	elseif tag == 0x1028 then
		payloadSubtree2:add("RssiMeasurement: ", buffer(bufIdx, 1):le_uint())
	end

	return leng
end

function parse_tras_config_resp(payloadSubtree, buffer, i, bufIdx)
	local length = 0
	local name = "tlv[" .. i .. "]"
	local payloadSubtree1 = payloadSubtree:add(nfapi_protocol, buffer(), name)
	
	payloadSubtree1:add("TAG : ", buffer(bufIdx + length, 2):uint())
	local tag = buffer(bufIdx + length, 2):uint()
	length = length + 2
	
	payloadSubtree1:add("LENGTH : ", buffer(bufIdx + length, 2):uint())
	local leng = buffer(bufIdx + length, 2):uint()
	length = length + 2
	
	if tag == 4096 then 
		payloadSubtree1:add("NFAPI_PNF_PARAM_GENERAL_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 256 then 
		payloadSubtree1:add("NFAPI_P7_VNF_ADDRESS_IPV4_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 257 then 
		payloadSubtree1:add("NFAPI_P7_VNF_ADDRESS_IPV6_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 258 then 
		payloadSubtree1:add("NFAPI_P7_VNF_PORT_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 259 then 
		payloadSubtree1:add("NFAPI_P7_PNF_ADDRESS_IPV4_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 260 then 
		payloadSubtree1:add("NFAPI_P7_PNF_ADDRESS_IPV6_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 261 then 
		payloadSubtree1:add("NFAPI_P7_PNF_PORT_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 262 then 
		payloadSubtree1:add("NFAPI_DL_TTI_TIMING_OFFSET_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 263 then 
		payloadSubtree1:add("NFAPI_UL_TTI_TIMING_OFFSET_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 264 then 
		payloadSubtree1:add("NFAPI_UL_DCI_TIMING_OFFSET_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 265 then 
		payloadSubtree1:add("NFAPI_TX_DATA_TIMING_OFFSET_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 286 then 
		payloadSubtree1:add("NFAPI_TIMING_WINDOW_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 287 then 
		payloadSubtree1:add("NFAPI_TIMING_INFO_MODE_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 288 then 
		payloadSubtree1:add("NFAPI_TIMING_INFO_PERIOD_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 289 then 
		payloadSubtree1:add("NFAPI_P7_IP_FRAGMENTATION_ALLOWED_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 290 then 
		payloadSubtree1:add("NFAPI_P7_TRANSPORT_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 291 then 
		payloadSubtree1:add("NFAPI_P7_PNF_ETHERNET_ADDRESS_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 292 then 
		payloadSubtree1:add("NFAPI_P7_VNF_ETHERNET_ADDRESS_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 293 then 
		payloadSubtree1:add("NFAPI_ECPRI_MESSAGE_TYPE_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 294 then 
		payloadSubtree1:add("NFAPI_ECPRI_PHY_TRANSPORT_ID_TAG: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 295 then 
		payloadSubtree1:add("NFAPI_P7_VERSION_USED: ", buffer(bufIdx + length, leng):uint())
	elseif tag == 3840 then
		local fapiParam = payloadSubtree1:add(nfapi_protocol, buffer(), "FAPI_MSG_BODY")
		fapiParam:add("numTlv: ", buffer(bufIdx + length, 1):le_uint())
		local num =  buffer(bufIdx + length, 1):le_uint()
		length = length + 1
		for i = 0, num - 1, 1 do
			local fapiParamTlv = fapiParam:add(nfapi_protocol, buffer(), "TLV["..i.."]")
			fapiParamTlv:add("TAG : ", buffer(bufIdx + length, 2):le_uint())
			local tag1 = buffer(bufIdx + length, 2):le_uint()
			length = length + 2
			
			fapiParamTlv:add("LENGTH : ", buffer(bufIdx + length, 2):le_uint())
			local leng1 = buffer(bufIdx + length, 2):le_uint()
			length = length + 2
			leng1 = parse_trans_config_tlv_value(fapiParamTlv, buffer, bufIdx + length, tag1, leng1)
			length = length + leng1
		end		
	end
	length = length + leng
	return length
end

function parse_t16_l16_v(tlvs1, buffer, i, bufIdx)
	local tlvs = tlvs1:add(nfapi_protocol, buffer(), "TLV["..i.."]")
	local length = 0
	tlvs:add("TAG : ", buffer(bufIdx + length, 2):le_uint())
	local tag1 = buffer(bufIdx + length, 2):le_uint()
	length = length + 2
	
	tlvs:add("LENGTH : ", buffer(bufIdx + length, 2):le_uint())
	local leng1 = buffer(bufIdx + length, 2):le_uint()
	length = length + 2
	
	local values = {}
	for i = 0, leng1 do
		values[i] = buffer(bufIdx + i, 1):le_uint()
	end
	payloadSubtree2:add("value: ", table.concat(values, ", "))
	length = length + leng1
	return length
end

function rf_param_res_tlv(payloadSubtree, buffer, i, bufIdx)
	local length = 0
	local subtree = payload:add(nfapi_protocol, buffer(), "TLV ["..i.."]")
	local tag = buffer(bufIdx +  length, 2):le_uint()
	subtree:add("TAG: ", buffer(bufIdx + length, 2):le_uint())
	length = length + 2
	subtree:add("Length: ", buffer(bufIdx + length, 2):le_uint())
	length = length + 2

	if tag == 0x6000 then 
		subtree:add("releaseCapbility: ", buffer(bufIdx + length, 2):le_uint())
		length = length + 2
	elseif tag == 0x6003 then
		subtree:add("freqScale: ", buffer(bufIdx +  length, 1):le_uint())
		length = length + 2
	else
		local len = buffer(bufIdx - length, 2):le_uint()
		for j = 0, len - 1, 1 do
			subtree:add("value["..j.."]: ", buffer(bufIdx +  length, 1):le_uint())
			length = length + 1
		end 
	end
	return length
end

function tx_rfchain_cfg_tlv(subtree, buffer, bufIdx)
	local length = 0
	subtree:add("RFchainIdx", buffer(bufIdx +  length, 1):le_uint())
	length = length + 1
	subtree:add("RFchain_ctrl", buffer(bufIdx +  length, 1):le_uint())
	length = length + 1
	subtree:add("bandType", buffer(bufIdx +  length, 1):le_uint())
	length = length + 1
	subtree:add("bandnum", buffer(bufIdx +  length, 2):le_uint())
	length = length + 2
	subtree:add("carrierIdx", buffer(bufIdx +  length, 1):le_uint())
	length = length + 1
	subtree:add("bandwidth", buffer(bufIdx +  length, 1):le_uint())
	length = length + 1
	subtree:add("carrierFreq", buffer(bufIdx +  length, 4):le_uint())
	length = length + 4
	subtree:add("nominalRmsOutPower", buffer(bufIdx +  length, 2):le_uint())
	length = length + 2
	subtree:add("nominalRmsInputPower", buffer(bufIdx +  length, 2):le_uint())
	length = length + 2
	subtree:add("gain", buffer(bufIdx +  length, 2):le_int())
	length = length + 2
	subtree:add("subcarrierSpacing", buffer(bufIdx +  length, 1):le_uint())
	length = length + 1
	subtree:add("cyclicPrefix", buffer(bufIdx +  length, 1):le_uint())
	length = length + 1
	return length
end

function rx_rfchain_cfg_tlv(subtree, buffer, bufIdx)
	local length = 0
	subtree:add("RFchainIdx", buffer(bufIdx +  length, 1):le_uint())
	length = length + 1
	subtree:add("RFchain_ctrl", buffer(bufIdx +  length, 1):le_uint())
	length = length + 1
	subtree:add("bandType", buffer(bufIdx +  length, 1):le_uint())
	length = length + 1
	subtree:add("bandnum", buffer(bufIdx +  length, 2):le_uint())
	length = length + 2
	subtree:add("carrierIdx", buffer(bufIdx +  length, 1):le_uint())
	length = length + 1
	subtree:add("bandwidth", buffer(bufIdx +  length, 1):le_uint())
	length = length + 1
	subtree:add("carrierFreq", buffer(bufIdx +  length, 4):le_uint())
	length = length + 4
	subtree:add("gain", buffer(bufIdx +  length, 2):le_int())
	length = length + 2
	subtree:add("subcarrierSpacing", buffer(bufIdx +  length, 1):le_uint())
	length = length + 1
	subtree:add("cyclicPrefix", buffer(bufIdx +  length, 1):le_uint())
	length = length + 1
	return length
end

function rf_config_req_tlv(payloadSubtree, buffer, i, bufIdx)
	local subtree = payloadSubtree:add(nfapi_protocol, buffer(), "TLV ["..i.."]")

	local length = 0
	local tag = buffer(bufIdx +  length, 2):le_uint()
	subtree:add("TAG: ", buffer(bufIdx + length, 2):le_uint())
	length = length + 2
	subtree:add("Length: ", buffer(bufIdx + length, 2):le_uint())
	length = length + 2

	if tag == 0x6100 then
		local tx_rf_chain = subtree:add(nfapi_protocol, buffer(), "TX_RF_CHAIN_CFG_TLV")
		length = length + tx_rfchain_cfg_tlv(tx_rf_chain, buffer, bufIdx + length)
	elseif tag == 0x6003 then
		local rx_rf_chain = subtree:add(nfapi_protocol, buffer(), "RX_RF_CHAIN_CFG_TLV")
		length = length + rx_rfchain_cfg_tlv(tx_rf_chain, buffer, bufIdx + length)
	elseif tag == 0x5555 then
		subtree:add("dal_rf_cfg_tlv_value: ", buffer(bufIdx +  length, 4):le_uint())
		length = length +  4
	else
		local len = buffer(bufIdx - length, 2):le_uint()
		for j = 0, len - 1, 1 do
			subtree:add("value["..j.."]: ", buffer(bufIdx +  length, 1):le_uint())
			length = length + 1
		end 
	end
	return length
end

function nfapi_protocol.dissector(buffer, pinfo, tree)
	length = buffer:len()
	if length == 0 then return end

	pinfo.cols.protocol = nfapi_protocol.name

	local subtree = tree:add(nfapi_protocol, buffer(), "nFAPI Protocol Data")
	local headerSubtree = subtree:add(nfapi_protocol, buffer(), "Header")
	local payloadSubtree = subtree:add(nfapi_protocol, buffer(), "Payload")

	headerSubtree:add(segment_length, buffer(0,2))
	headerSubtree:add(more_Flag_Segment_Number, buffer(2,1))
	headerSubtree:add(sequence_Number, buffer(3,1))
	headerSubtree:add(transmit_Timestamp, buffer(4,4):uint())

	headerSubtree:add(sru_Termination_Type, buffer(8,1))
	headerSubtree:add(phy_Id, buffer(9,1))

	local msgType_number = buffer(10,2):uint()
	local msgType_name = get_opcode_name(msgType_number)
	headerSubtree:add(msg_Type, buffer(10,2)):append_text(" (" .. msgType_name .. ")")

	headerSubtree:add(message_length, buffer(12,4))
	
	-- Set the Info column text to the message type name
    pinfo.cols.info = msgType_name
  
	if msgType_name == "P5_NFAPI_PNF_READY_INDICATION" then
		payloadSubtree:add(version_info, buffer(16,4))
	elseif msgType_name == "P5_NFAPI_PNF_PARAM_RESPONSE" then
		payloadSubtree:add(error_code, buffer(16, 1))
		payloadSubtree:add(num_tlv, buffer(17,1))
		local num = buffer(17,1):uint()
		local bufIdx = 18
		for i = 0, num - 1, 1 do
			parse_p5_param_resp_tlv(payloadSubtree, buffer, i, bufIdx)
			bufIdx = bufIdx + 31
		end
	elseif msgType_name == "P5_NFAPI_PNF_CONFIG_REQUEST" then
		payloadSubtree:add(num_tlv, buffer(16, 1))
	elseif msgType_name == "P5_NFAPI_PNF_CONFIG_RESPONSE" then
		payloadSubtree:add(error_code, buffer(16, 1))
	elseif msgType_name == "P5_NFAPI_PNF_START_RESPONSE" then
		payloadSubtree:add(error_code, buffer(16, 1))
	elseif msgType_name == "P5_NFAPI_PNF_STOP_RESPONSE" then
		payloadSubtree:add(error_code, buffer(16, 1))
	elseif msgType_name == "EP5_MSG_TYPE_PARAM_REQUEST" then
	elseif msgType_name == "EP5_MSG_TYPE_PARAM_RESPONSE" then
		payloadSubtree:add(error_code, buffer(16, 1))
		payloadSubtree:add(num_tlv, buffer(17, 1))
		local num = buffer(17, 1):uint()
		local bufIdx = 18
		for i = 0, num - 1, 1 do
			local length = parse_tras_param_resp(payloadSubtree, buffer, i, bufIdx)
			bufIdx = bufIdx + length
		end	
	elseif msgType_name == "EP5_MSG_TYPE_CONFIG_REQUEST" then
		payloadSubtree:add(num_tlv, buffer(16, 1))
		local num = buffer(16, 1):uint()
		local bufIdx = 17
		for i = 0, num - 1, 1 do
			local length = parse_tras_config_resp(payloadSubtree, buffer, i, bufIdx)
			bufIdx = bufIdx + length
		end	
	elseif msgType_name == "EP5_MSG_TYPE_CONFIG_RESPONSE" then
		payloadSubtree:add(error_code, buffer(16, 1):le_uint())
		payloadSubtree:add("num_unsupported_invalid_tlvs", buffer(17, 1):le_uint())
		local num_unsupported_invalid_tlvs = buffer(17, 1):le_uint()
		payloadSubtree:add("num_invalid_tlvs_only_idle_config", buffer(18, 1):le_uint())
		local num_invalid_tlvs_only_idle_config = buffer(18, 1):le_uint()
		payloadSubtree:add("num_missing_tlvs", buffer(19, 1):le_uint())
		local num_missing_tlvs = buffer(19, 1):le_uint()
		local bufIdx = 20
		
		local tlvs1 = payloadSubtree:add(nfapi_protocol, buffer(), "list of invalid_tlvs")
		for i = 0, num_unsupported_invalid_tlvs - 1 do
			local length = parse_t16_l16_v(tlvs1, buffer, i, bufIdx)
			bufIdx = bufIdx + length
		end
		
		local tlvs2 = payloadSubtree:add(nfapi_protocol, buffer(), "list of only_idle_config_tlvs")
		for i = 0, num_invalid_tlvs_only_idle_config - 1 do
			local length = parse_t16_l16_v(tlvs2, buffer, i, bufIdx)
			bufIdx = bufIdx + length
		end
		
		local tlvs3 = payloadSubtree:add(nfapi_protocol, buffer(), "list of missing_Tlvs")
		for i = 0, num_missing_tlvs - 1 do
			local length = parse_t16_l16_v(tlvs3, buffer, i, bufIdx)
			bufIdx = bufIdx + length
		end	
	elseif msgType_name == "EP5_MSG_TYPE_START_REQUEST" then
	elseif msgType_name == "P5_NFAPI_START_RESPONSE" then
		payloadSubtree:add(error_code, buffer(16, 1):le_uint())
	elseif msgType_name == "EP5_MSG_TYPE_STOP_REQUEST" then
	elseif msgType_name == "EP5_MSG_TYPE_STOP_INDICATION" then
		payloadSubtree:add("SFN: ", buffer(16, 2):le_uint())
		payloadSubtree:add("Slot: ", buffer(18, 2):le_uint())
	elseif msgType_name == "EP5_MSG_TYPE_ERROR_INDICATION" then
		payloadSubtree:add("SFN: ", buffer(16, 2):le_uint())
		payloadSubtree:add("Slot: ", buffer(18, 2):le_uint())
		payloadSubtree:add("MessageId: ", buffer(20, 1):le_uint())
		payloadSubtree:add(error_code, buffer(21, 1):le_uint())
	elseif msgType_name == "EP5_MSG_TYPE_RESET_REQUEST" then
	elseif msgType_name == "EP5_MSG_TYPE_RESET_INDICATION" then	
	elseif msgType_name == "P19_NFAPI_RF_PARAM_REQUEST" then
	elseif msgType_name == "P19_NFAPI_RF_PARAM_RESPONSE" then
		payloadSubtree:add(error_code, buffer(16, 1):uint())
		payloadSubtree:add(num_tlv, buffer(17, 1))
		local num = buffer(17, 1):uint()
		local bufIdx = 18
		for i = 0, num - 1, 1 do
			local length = rf_param_res_tlv(payloadSubtree, buffer, i, bufIdx)
			bufIdx = bufIdx + length
		end
	elseif msgType_name == "P19_NFAPI_RF_CONFIG_REQUEST" then
		payloadSubtree:add(num_tlv, buffer(16, 1))
		local num = buffer(16, 1):uint()
		local bufIdx = 17
		for i = 0, num - 1, 1 do
			local length = rf_config_req_tlv(payloadSubtree, buffer, i, bufIdx)
			bufIdx = bufIdx + length
		end	
	elseif msgType_name == "P19_NFAPI_RF_CONFIG_RESPONSE" then
		local bufIdx = 16
		payloadSubtree:add(error_code, buffer(bufIdx, 1):le_uint())
		bufIdx = bufIdx + 1
		payloadSubtree:add("numOfInvalidOrUnsupportedTlvs: ", buffer(bufIdx, 1):le_uint())
		local num1 = buffer(bufIdx, 1):le_uint()
		bufIdx = bufIdx + 1
		payloadSubtree:add("numOfInvalidTlvsThatCanOnlyBeConfiguredInIDLE: ", buffer(bufIdx, 1):le_uint())
		local num2 = buffer(bufIdx, 1):le_uint()
		bufIdx = bufIdx + 1
		payloadSubtree:add("numOfInvalidTlvsThatCanOnlyBeConfiguredInRUNNING: ", buffer(bufIdx, 1):le_uint())
		local num3 = buffer(bufIdx, 1):le_uint()
		bufIdx = bufIdx + 1
		payloadSubtree:add("numOfMissingTlvs: ", buffer(bufIdx, 1):le_uint())
		local num4 = buffer(bufIdx, 1):le_uint()
		bufIdx = bufIdx + 1

		local tlv1 = payload:add(nfapi_protocol, buffer(), "list of numOfInvalidOrUnsupportedTlvs")
		for i = 0, num1 - 1 do
			tlv1:add("TLV["..i.."]: ", buffer(bufIdx, 2):le_uint())
			bufIdx = bufIdx + 2
		end
		
		local tlv2 = payload:add(nfapi_protocol, buffer(), "list of numOfInvalidTlvsThatCanOnlyBeConfiguredInIDLE")
		for i = 0, num2 - 1 do
			tlv2:add("TLV["..i.."]: ", buffer(bufIdx, 2):le_uint())
			bufIdx = bufIdx + 2
		end
		
		local tlv3 = payload:add(nfapi_protocol, buffer(), "list of numOfInvalidTlvsThatCanOnlyBeConfiguredInRUNNING")
		for i = 0, num3 - 1 do
			tlv3:add("TLV["..i.."]: ", buffer(bufIdx, 2):le_uint())
			bufIdx = bufIdx + 2
		end
		
		local tlv4 = payload:add(nfapi_protocol, buffer(), "list of numOfMissingTlvs")
		for i = 0, num4 - 1 do
			tlv4:add("TLV["..i.."]: ", buffer(bufIdx, 2):le_uint())
			bufIdx = bufIdx + 2
		end
		
	elseif msgType_name == "P19_NFAPI_RF_START_REQUEST" then
	elseif msgType_name == "P19_NFAPI_RF_START_RESPONSE" then	
		payloadSubtree:add(error_code, buffer(16, 1):uint())
	end
end

local sctp_port = DissectorTable.get("sctp.port")
sctp_port:add(8000, nfapi_protocol)