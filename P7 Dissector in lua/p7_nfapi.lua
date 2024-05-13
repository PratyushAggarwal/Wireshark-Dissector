nfapi_p7_protocol = Proto("nFAPI_P7",  "nFAPI P7 Protocol")

MAX_NUM_CORESET_CARRIER = 2
DCI_PAYLOAD_BYTE_LEN = 16
MAX_CB_POS_LEN = 19
MAX_NUM_PREAMBLE_CARRIER = 16
MAX_HARQ_BIT_LEN = 3
MAX_CSI_PART1BIT_LEN = 14
MAX_CSI_PART2BIT_LEN = 14
FTL_MAX_RB = 273
FTL_MAX_NUM_ALLOC_IN_PRG = 1

function decode_nfapi_hdr(subtree, buffer, bufIdx)
	subtree:add("sequenceNumber: ", buffer(0, 2):uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("totalSDULength: ", buffer(bufIdx[1], 3):uint())
	bufIdx[1] = bufIdx[1] + 3
	subtree:add("byteOffset: ", buffer(bufIdx[1], 3):uint())
	bufIdx[1] = bufIdx[1] + 3
	subtree:add("transmitTimestamp: ", buffer(bufIdx[1], 4):uint())
	bufIdx[1] = bufIdx[1] + 4
end

function decode_msg_hdr(subtree, buffer, bufIdx)
	subtree:add("sruTerminationType: ", buffer(bufIdx[1], 1):uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("phyId: ", buffer(bufIdx[1], 1):uint())
	bufIdx[1] = bufIdx[1] + 1
	local msgType = buffer(bufIdx[1], 2):uint()
	
	local opcode_to_message_type = {
		[384] = "NFAPI_P7_DL_NODE_SYNC",
		[385] = "NFAPI_P7_UL_NODE_SYNC",
		[386] = "NFAPI_P7_TIMING_INFO",
		[768] = "NFAPI_OUT_OF_SYNC",
		[128] = "P7_DL_TTI_REQUEST",
		[129] = "P7_UL_TTI_REQUEST",
		[130] = "P7_SLOT_INDICATION",
		[131] = "P7_UL_DCI_REQUEST",
		[132] = "P7_TX_DATA_REQUEST",
		[133] = "P7_RX_DATA_INDICATION",
		[134] = "P7_CRC_INDICATION",
		[135] = "P7_UCI_INDICATION",
		[136] = "P7_SRS_INDICATION",
		[137] = "P7_RACH_INDICATION",
		[138] = "P7_PDCCH_DL_TTI_REQUEST",
		[139] = "P7_PDSCH_DL_TTI_REQUEST",
		[140] = "P7_SSB_CSIRS_DL_TTI_REQUEST",
		[141] = "P7_PUSCH_UL_TTI_REQUEST",
		[142] = "P7_PUCCH_UL_TTI_REQUEST",
		[143] = "P7_PUCCH_UCI01_INDICATION",
		[144] = "P7_PUCCH_UCI234_INDICATION",
		[145] = "P7_PUSCH_UCI_INDICATION",
		[146] = "P7_SRS_UL_TTI_REQUEST",
		[147] = "P7_PREC_MATRIX_TBL_CFG_REQ",
		[148] = "P7_DIGITAL_BF_TBL_CFG_REQ",
		[149] = "P7_DL_PREC_AND_BF_TTI_REQ",
		[150] = "P7_UL_BF_TTI_REQ",
		[151] = "P7_SRS_PWR_INDICATION",
		[152] = "P7_SRS_BEAMFORM_INDICATION"
	}
	local msgTypename = opcode_to_message_type[msgType] or "Unknown"
	subtree:add("msgType: ", buffer(bufIdx[1], 2):uint()):append_text("("..msgTypename..")")
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("msgLen: ", buffer(bufIdx[1], 4):uint())
	bufIdx[1] = bufIdx[1] + 4
	return msgTypename
end

function decode_slot_info(subtree, buffer, bufIdx)
	local slot_info = subtree:add(nfapi_p7_protocol, buffer(), "SlotInfo")
	slot_info:add("SFN: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	slot_info:add("Slot: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
function decode_coreset_info(subtree, buffer, bufIdx)
	subtree:add("bwpSize: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("bwpStart: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("subcarrierSpacing: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("cyclicPrefix: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("startSymbolIndex: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("durationSymbols: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1

	-- Parsing freqDomainResource
	local freqDomainResource_str = ""
	for i = 0, 5 do
		freqDomainResource_str = freqDomainResource_str .. string.format("%02X ", buffer(bufIdx[1], 1):uint())
		bufIdx[1] = bufIdx[1] + 1
	end
	subtree:add("freqDomainResource: ", freqDomainResource_str)

	subtree:add("cceRegMappingType: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("regBundleSize: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("interleaverSize: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("coreSetType: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("shiftIndex: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("precoderGranularity: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1

	-- Padding
	subtree:add("---padding(3)---")
	bufIdx[1] = bufIdx[1] + 3
end

function calc_rbStart_and_rbSize_from_riv(bwp_size, riv, rb_start, num_rb)
    local n = 1
    local m = 0

    while n <= bwp_size do
        m = 0
        while m <= (bwp_size - n) do
            if (n - 1) <= (bwp_size / 2) then
                if riv == (bwp_size * (n - 1)) + m then
                    num_rb = n
                    rb_start = m
                end
            else
                if riv == (bwp_size * (bwp_size - n + 1)) + bwp_size - 1 - m then
                    num_rb = n
                    rb_start = m
                end
            end
            m = m + 1
        end
        n = n + 1
    end

    return 0
end


function decode_dl_dci10_rar(subtree, buffer, bufIdx)
	local riv_8b = buffer(bufIdx[1], 1):le_uint()
	bufIdx[1] = bufIdx[1] + 1
	
	local value = buffer(bufIdx[1], 1):le_uint()
	local riv_1b = extractBits(0, 1, value1)
	bufIdx[1] = bufIdx[1] + 1

	-- Combine riv_8b and riv_1b to get riv_9b
	local riv_9b = (riv_8b * 2) + riv_1b
	subtree:add("bits16_1: "):append_text(riv_9b)

	if SETTING_DCI_RIV_DECODE_ENABLED == 1 then
		local rb_start = 0
		local rb_size = 0
		-- Calculate rb_start and rb_size using riv_9b (24 is assumed for the parameter)
		local dummy = calc_rbStart_and_rbSize_from_riv(24, riv_9b, rb_start, rb_size)
		subtree:add("_dciRiv_rbStart: ", rb_start)
		subtree:add("_dciRiv_rbSize: ", rb_size)
	end

	subtree:add("k0Index_4b: ", buffer(bufIdx[1], 1):bitfield(0, 4))
	subtree:add("vrb2Prb_1b: ", buffer(bufIdx[1], 1):bitfield(4, 1))
	subtree:add("mcs_5b: ", buffer(bufIdx[1], 1):bitfield(5, 5))
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("tbScalingField_2b: ", buffer(bufIdx[1], 1):bitfield(2, 2))
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("reserved_16b: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2

end

function decode_dl_dci10_si(subtree, buffer, bufIdx)
	local riv_8b = buffer(bufIdx[1], 1):le_uint()
	bufIdx[1] = bufIdx[1] + 1
	local riv_1b = buffer(bufIdx[1], 1):bitfield(0, 1)
	bufIdx[1] = bufIdx[1] + 1
	local riv_9b = (riv_8b * 2) + riv_1b

	local _dciRiv_rbStart = 0
	local _dciRiv_rbSize = 0
	if SETTING_DCI_RIV_DECODE_ENABLED == 1 then
		local rb_start = 0
		local rb_size = 0
		-- Calculate rb_start and rb_size using riv_9b (24 is assumed for the parameter)
		local dummy = calc_rbStart_and_rbSize_from_riv(24, riv_9b, rb_start, rb_size)
		subtree:add("_dciRiv_rbStart: ", rb_start)
		subtree:add("_dciRiv_rbSize: ", rb_size)
	end

	subtree:add("k0Index_4b: ", buffer(bufIdx[1], 1):bitfield(0, 4))
	subtree:add("vrb2Prb_1b: ", buffer(bufIdx[1], 1):bitfield(4, 1))
	subtree:add("mcs_5b: ", buffer(bufIdx[1], 1):bitfield(5, 5))
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("rv_2b: ", buffer(bufIdx[1], 1):bitfield(0, 2))
	subtree:add("siInfInd_1b: ", buffer(bufIdx[1], 1):bitfield(2, 1))
	subtree:add("reserved_15b: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2

end

function decode_dl_dci10_par(subtree, buffer, bufIdx)
	-- Define variables
	local shortMsgI_2b = buffer(bufIdx[1], 1):bitfield(0, 2)
	bufIdx[1] = bufIdx[1] + 1
	local reserved_8b = buffer(bufIdx[1], 1):le_uint()
	bufIdx[1] = bufIdx[1] + 1

	-- Splitting uint9 into two parts
	local riv_8b = buffer(bufIdx[1], 1):le_uint()
	bufIdx[1] = bufIdx[1] + 1
	local riv_1b = buffer(bufIdx[1], 1):bitfield(0, 1)
	bufIdx[1] = bufIdx[1] + 1
	local riv_9b = (riv_8b * 2) + riv_1b

	local _dciRiv_rbStart = 0
	local _dciRiv_rbSize = 0
	if SETTING_DCI_RIV_DECODE_ENABLED == 1 then
		local rb_start = 0
		local rb_size = 0
		-- Calculate rb_start and rb_size using riv_9b (24 is assumed for the parameter)
		local dummy = calc_rbStart_and_rbSize_from_riv(24, riv_9b, rb_start, rb_size)
		subtree:add("_dciRiv_rbStart: ", rb_start)
		subtree:add("_dciRiv_rbSize: ", rb_size)
	end

	local k0Idx_4b = buffer(bufIdx[1], 1):bitfield(0, 4)
	local vrb2Prb_1b = buffer(bufIdx[1], 1):bitfield(4, 1)
	local mcs_5b = buffer(bufIdx[1], 1):bitfield(5, 5)
	bufIdx[1] = bufIdx[1] + 1
	local tbScalingField_2b = buffer(bufIdx[1], 1):bitfield(0, 2)
	local reserved1_6b = buffer(bufIdx[1], 1):bitfield(2, 6)
	bufIdx[1] = bufIdx[1] + 1

end

function decode_dl_dci10_tcrnti(subtree, buffer, bufIdx)
	-- Define variables
	local dci0or1_1b = buffer(bufIdx[1], 1):bitfield(0, 1)
	bufIdx[1] = bufIdx[1] + 1

	-- Splitting uint9 into two parts
	local riv_8b = buffer(bufIdx[1], 1):le_uint()
	bufIdx[1] = bufIdx[1] + 1
	local riv_1b = buffer(bufIdx[1], 1):bitfield(0, 1)
	bufIdx[1] = bufIdx[1] + 1
	local riv_9b = (riv_8b * 2) + riv_1b

	local _dciRiv_rbStart = 0
	local _dciRiv_rbSize = 0
	if SETTING_DCI_RIV_DECODE_ENABLED == 1 then
		local rb_start = 0
		local rb_size = 0
		-- Calculate rb_start and rb_size using riv_9b (24 is assumed for the parameter)
		local dummy = calc_rbStart_and_rbSize_from_riv(24, riv_9b, rb_start, rb_size)
		subtree:add("_dciRiv_rbStart: ", rb_start)
		subtree:add("_dciRiv_rbSize: ", rb_size)
	end

	local value = buffer(bufIdx[1], 4):le_uint()
	local k0Idx_4b = value:bitfield(0, 4)
	local vrb2Prb_1b = value:bitfield(4, 1)
	local mcs_5b = value:bitfield(5, 5)
	local ndi_1b = value:bitfield(10, 1)
	local rv_2b = value:bitfield(11, 2)
	local hqProcId_4b = value:bitfield(13, 4)
	local dai_2b = value:bitfield(17, 2)
	local tpc_2b = value:bitfield(19, 2)
	local pucchResIdx_3b = value:bitfield(21, 3)
	local k1Index_3b = value:bitfield(24, 3)
	bufIdx[1] = bufIdx[1] + 4

	-- Add fields to the subtree
	subtree:add("dci0or1_1b: ", dci0or1_1b)
	subtree:add("riv_9b: ", riv_9b)
	subtree:add("_dciRiv_rbStart: ", _dciRiv_rbStart)
	subtree:add("_dciRiv_rbSize: ", _dciRiv_rbSize)
	subtree:add("k0Idx_4b: ", k0Idx_4b)
	subtree:add("vrb2Prb_1b: ", vrb2Prb_1b)
	subtree:add("mcs_5b: ", mcs_5b)
	subtree:add("ndi_1b: ", ndi_1b)
	subtree:add("rv_2b: ", rv_2b)
	subtree:add("hqProcId_4b: ", hqProcId_4b)
	subtree:add("dai_2b: ", dai_2b)
	subtree:add("tpc_2b: ", tpc_2b)
	subtree:add("pucchResIdx_3b: ", pucchResIdx_3b)
	subtree:add("k1Index_3b: ", k1Index_3b)

end

function decode_dl_dci11_crnt(subtree, buffer, bufIdx)
	-- Define variables
	local dci0or1_1b = buffer(bufIdx[1], 1):bitfield(0, 1)
	bufIdx[1] = bufIdx[1] + 1

	-- Splitting uint16 into two parts
	local riv_8b_1 = buffer(bufIdx[1], 1):le_uint()
	bufIdx[1] = bufIdx[1] + 1
	local riv_8b_2 = buffer(bufIdx[1], 1):le_uint()
	bufIdx[1] = bufIdx[1] + 1
	local riv_16b = (riv_8b_1 * 2) + riv_8b_2

	local _dciRiv_rbStart = 0
	local _dciRiv_rbSize = 0
	if SETTING_DCI_RIV_DECODE_ENABLED == 1 then
		local rb_start = 0
		local rb_size = 0
		-- Calculate rb_start and rb_size using riv_9b (24 is assumed for the parameter)
		local dummy = calc_rbStart_and_rbSize_from_riv(24, riv_9b, rb_start, rb_size)
		subtree:add("_dciRiv_rbStart: ", rb_start)
		subtree:add("_dciRiv_rbSize: ", rb_size)
	end

	local k0Index_2b = buffer(bufIdx[1], 1):bitfield(0, 2)
	local mcs_5b = buffer(bufIdx[1], 1):bitfield(2, 5)
	local ndi_1b = buffer(bufIdx[1], 1):bitfield(7, 1)
	local rv_2b = buffer(bufIdx[1], 1):bitfield(8, 2)
	local hqProcId_4b = buffer(bufIdx[1], 1):bitfield(10, 4)
	local dai_2b = buffer(bufIdx[1], 1):bitfield(14, 2)
	local tpc_2b = buffer(bufIdx[1], 1):bitfield(16, 2)
	local pucchResIdx_3b = buffer(bufIdx[1], 1):bitfield(18, 3)
	local k1Index_3b = buffer(bufIdx[1], 1):bitfield(21, 3)
	local dmrsPortIdx_4b = buffer(bufIdx[1], 1):bitfield(24, 4)
	local srsReqBits_2b = buffer(bufIdx[1], 1):bitfield(28, 2)
	local dmrsScid_1b = buffer(bufIdx[1], 1):bitfield(30, 1)
	bufIdx[1] = bufIdx[1] + 4

	-- Add fields to the subtree
	subtree:add("dci0or1_1b: ", dci0or1_1b)
	subtree:add("riv_16b: ", riv_16b)
	subtree:add("_dciRiv_rbStart: ", _dciRiv_rbStart)
	subtree:add("_dciRiv_rbSize: ", _dciRiv_rbSize)
	subtree:add("k0Index_2b: ", k0Index_2b)
	subtree:add("mcs_5b: ", mcs_5b)
	subtree:add("ndi_1b: ", ndi_1b)
	subtree:add("rv_2b: ", rv_2b)
	subtree:add("hqProcId_4b: ", hqProcId_4b)
	subtree:add("dai_2b: ", dai_2b)
	subtree:add("tpc_2b: ", tpc_2b)
	subtree:add("pucchResIdx_3b: ", pucchResIdx_3b)
	subtree:add("k1Index_3b: ", k1Index_3b)
	subtree:add("dmrsPortIdx_4b: ", dmrsPortIdx_4b)
	subtree:add("srsReqBits_2b: ", srsReqBits_2b)
	subtree:add("dmrsScid_1b: ", dmrsScid_1b)

end

function decode_dl_dci00_crnt(subtree, buffer, bufIdx)
	-- Define variables
	local dci0or1_1b = buffer(bufIdx[1], 1):bitfield(0, 1)
	bufIdx[1] = bufIdx[1] + 1

	-- Splitting uint16 into two parts
	local riv_8b_1 = buffer(bufIdx[1], 1):le_uint()
	bufIdx[1] = bufIdx[1] + 1
	local riv_8b_2 = buffer(bufIdx[1], 1):le_uint()
	bufIdx[1] = bufIdx[1] + 1
	local riv_16b = (riv_8b_1 * 2) + riv_8b_2

	local _dciRiv_rbStart = 0
	local _dciRiv_rbSize = 0
	if SETTING_DCI_RIV_DECODE_ENABLED == 1 then
		local rb_start = 0
		local rb_size = 0
		-- Calculate rb_start and rb_size using riv_9b (24 is assumed for the parameter)
		local dummy = calc_rbStart_and_rbSize_from_riv(24, riv_9b, rb_start, rb_size)
		subtree:add("_dciRiv_rbStart: ", rb_start)
		subtree:add("_dciRiv_rbSize: ", rb_size)
	end

	local k2Index_4b = buffer(bufIdx[1], 1):bitfield(0, 4)
	local freqHop_1b = buffer(bufIdx[1], 1):bitfield(4, 1)
	local mcs_5b = buffer(bufIdx[1], 1):bitfield(5, 5)
	local ndi_1b = buffer(bufIdx[1], 1):bitfield(10, 1)
	local rv_2b = buffer(bufIdx[1], 1):bitfield(11, 2)
	local hqProcId_4b = buffer(bufIdx[1], 1):bitfield(13, 4)
	local tpc_2b = buffer(bufIdx[1], 1):bitfield(17, 2)
	bufIdx[1] = bufIdx[1] + 2

	-- Add fields to the subtree
	subtree:add("dci0or1_1b: ", dci0or1_1b)
	subtree:add("riv_16b: ", riv_16b)
	subtree:add("_dciRiv_rbStart: ", _dciRiv_rbStart)
	subtree:add("_dciRiv_rbSize: ", _dciRiv_rbSize)
	subtree:add("k2Index_4b: ", k2Index_4b)
	subtree:add("freqHop_1b: ", freqHop_1b)
	subtree:add("mcs_5b: ", mcs_5b)
	subtree:add("ndi_1b: ", ndi_1b)
	subtree:add("rv_2b: ", rv_2b)
	subtree:add("hqProcId_4b: ", hqProcId_4b)
	subtree:add("tpc_2b: ", tpc_2b)
end

function decode_dci_pdu_info(subtree, buffer, bufIdx)
	local rnti = buffer(bufIdx[1], 2):le_uint()
	subtree:add("rnti: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("scramblingId: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	
	subtree:add("scramblingRnti: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("cceIndex: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	local payloadSizeBits = buffer(bufIdx[1], 1):le_uint()
	subtree:add("payloadSizeBits: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	
	local value1 = buffer(bufIdx[1], 2):le_uint()
	bufIdx[1] = bufIdx[1] + 2
	local bits16_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits16_1  0x"..string.format("%x", value1))
	bits16_1:add("aggregationLevel: ", extractBits(0, 5, value1))
	bits16_1:add("beta_PDCCH_1_0: ", extractBits(5, 5, value1))
	bits16_1:add("powerControlOffsetSS: ", extractBits(10, 2, value1))
	bits16_1:add("csIdx: ", extractBits(12, 2, value1))
	bits16_1:add("pad: ", extractBits(14, 2, value1))

	if payloadSizeBits == 37 then
		if rnti <= 16920 then
			-- SDci_10_Rar_37b_Params dl_dci10_rar;
			local dl_dci10_rar = subtree:add(nfapi_p7_protocol, buffer(), "dl_dci10_rar")
			decode_dl_dci10_rar(dl_dci10_rar, buffer, bufIdx)
		elseif rnti == 0xffff then
			-- SDci_10_Si_37b_Params dl_dci10_si;
			local dl_dci10_si = subtree:add(nfapi_p7_protocol, buffer(), "dl_dci10_si")
			decode_dl_dci10_si(dl_dci10_si, buffer, bufIdx)
		elseif rnti == 0xfffe then
			-- SDci_10_Pag_37b_Params dl_dci10_pag;
			local dl_dci10_par = subtree:add(nfapi_p7_protocol, buffer(), "dl_dci10_par")
			decode_dl_dci10_par(dl_dci10_par, buffer, bufIdx)
		else
			-- SDci_10_tcrnti_37b_Params dl_dci10_tcrnti;
			local dl_dci10_tcrnti = subtree:add(nfapi_p7_protocol, buffer(), "dl_dci10_tcrnti")
			decode_dl_dci10_tcrnti(dl_dci10_tcrnti, buffer, bufIdx)
		end
		subtree:add("remaining_bytes: ", buffer(bufIdx[1], 11):string())
	elseif payloadSizeBits == 48 then
		-- SDci_11_crnti_48b_Params dl_dci11_crnti;
		local dl_dci11_crnti = subtree:add(nfapi_p7_protocol, buffer(), "dl_dci11_crnti")
		decode_dl_dci11_crnt(dl_dci11_crnti, buffer, bufIdx)
		subtree:add("remaining_bytes: ", buffer(bufIdx[1], 10):string())
	elseif payloadSizeBits == 44 then
		-- SDci_00_crnti_44b_Params ul_dci00_crnti;
		local ul_dci00_crnti = subtree:add(nfapi_p7_protocol, buffer(), "dl_dci00_crnti")
		decode_dl_dci00_crnt(ul_dci00_crnti, buffer, bufIdx)
		subtree:add("remaining_bytes: ", buffer(bufIdx[1], 10):string())
	else
		for i = 0, 15 do
			subtree:add("payload["..i.."] ", buffer(bufIdx[1], 1):le_uint())
			bufIdx[1] = bufIdx[1] + 1
		end
	end
	
end

function decode_pdcch_pdu_info(subtree, buffer, bufIdx)
	local pdcchpdu = subtree:add(nfapi_p7_protocol, buffer(), "PdcchPduInfo")
	for i = 0, MAX_NUM_CORESET_CARRIER - 1, 1 do
		local coreset = pdcchpdu:add(nfapi_p7_protocol, buffer(), "CoresetInfo["..i.."]")
		decode_coreset_info(coreset, buffer, bufIdx)
	end
	
	local numEntries = 0
	
	for i = 0, MAX_NUM_CORESET_CARRIER - 1, 1 do
		pdcchpdu:add("numDci["..i.."]: ", buffer(bufIdx[1], 1):le_uint())
		numEntries = numEntries + buffer(bufIdx[1], 1):le_uint()
		bufIdx[1] = bufIdx[1] + 1
	end
	
	pdcchpdu:add("---padding(2)---")
	bufIdx[1] = bufIdx[1] + 2
	
	for i = 0, numEntries - 1, 1 do
		local dcipdu = pdcchpdu:add(nfapi_p7_protocol, buffer(), "dciPduInfo["..i.."]")
		decode_dci_pdu_info(dcipdu, buffer, bufIdx)
	end
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
function decode_bwp(subtree, buffer, bufIdx)
	subtree:add("bwpStart: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("bwpSize: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("subcarrierSpacing: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("cyclicPrefix: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("---padding(2bytes)---")
	bufIdx[1] = bufIdx[1] + 2
end

function decode_rb_bit_map_info(subtree, buffer, bufIdx)
	for i = 0, 35 do
		subtree:add("rbBitmap["..i.."]", buffer(bufIdx[1], 1):le_uint())
		bufIdx[1] = bufIdx[1] + 1
	end
end

function extractBits(startIndex, length, number)
    local result = 0
    local factor = 1
    for i = startIndex, startIndex + length - 1, 1 do
        local bitValue = math.floor(number / (2 ^ i)) % 2
        result = result + bitValue * factor
        factor = factor * 2
    end
    return result
end


function decode_pdsch_pdu_info(subtree, buffer, bufIdx)
	subtree:add("rnti: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("pduIndex: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("bwpIdx: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("dataScramblingId: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("dlDmrsScramblingId: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("tbSizeCw0: ", buffer(bufIdx[1], 4):le_uint())
	bufIdx[1] = bufIdx[1] + 4
	subtree:add("tbSizeCw1: ", buffer(bufIdx[1], 4):le_uint())
	bufIdx[1] = bufIdx[1] + 4
	
	local rbBitmapInfo = subtree:add(nfapi_p7_protocol, buffer(), "rbBitmapInfo")
	decode_rb_bit_map_info(rbBitmapInfo, buffer, bufIdx)
	
	local value1 = buffer(bufIdx[1], 4):le_uint()
	local scid = extractBits(0, 1, value1)
	local pduBitmap = extractBits(1, 2, value1)
	local nrOfLayers = extractBits(3, 4, value1)
	local refPoint = extractBits(7, 1, value1)
	local dmrsConfigType = extractBits(8, 1, value1)
	local dlDmrsSymbPos = extractBits(9, 14, value1)
	local numDmrsCdmGrpsNoData = extractBits(23, 2, value1)
	local resourceAlloc = extractBits(25, 1, value1)
	local nrOfCodewords = extractBits(26, 2, value1)
	local qamModOrderCw0 = extractBits(28, 4, value1)
	local bits32_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits32_1  0x"..string.format("%x", value1))
	bits32_1:add("scid: ", scid)
	bits32_1:add("pduBitmap: ", pduBitmap)
	bits32_1:add("nrOfLayers: ", nrOfLayers)
	bits32_1:add("refPoint: ", refPoint)
	bits32_1:add("dmrsConfigType: ", dmrsConfigType)
	bits32_1:add("dlDmrsSymbPos: ", dlDmrsSymbPos)
	bits32_1:add("numDmrsCdmGrpsNoData: ", numDmrsCdmGrpsNoData)
	bits32_1:add("resourceAlloc: ", resourceAlloc)
	bits32_1:add("nrOfCodewords: ", nrOfCodewords)
	bits32_1:add("qamModOrderCw0: ", qamModOrderCw0)
	bufIdx[1] = bufIdx[1] + 4
	
	local value2 = buffer(bufIdx[1], 4):le_uint()
	bufIdx[1] = bufIdx[1] + 4
	local bits32_2 = subtree:add(nfapi_p7_protocol, buffer(), "bits32_2  0x"..string.format("%x", value2))
	bits32_2:add("dmrsPorts: ", extractBits(0, 12, value2))
	bits32_2:add("qamModOrderCw1: ", extractBits(12, 4, value2))
	bits32_2:add("rvIndexCw0: ", extractBits(16, 2, value2))
	bits32_2:add("rvIndexCw1: ", extractBits(18, 2, value2))
	bits32_2:add("rbStart: ", extractBits(20, 9, value2))
	bits32_2:add("vrbtoPrbMapping: ", extractBits(29, 2, value2))
	bits32_2:add("ptrsFreqDensity: ", extractBits(31, 1, value2))
	
	local value3 = buffer(bufIdx[1], 4):le_uint()
	bufIdx[1] = bufIdx[1] + 4
	local bits32_3 = subtree:add(nfapi_p7_protocol, buffer(), "bits32_3  0x"..string.format("%x", value3))
	bits32_3:add("rbSize: ", extractBits(0, 9, value3))
	bits32_3:add("startSymbolIndex: ", extractBits(9, 4, value3))
	bits32_3:add("nrOfSymbols: ", extractBits(13, 4, value3))
	bits32_3:add("ptrsPortIndex: ", extractBits(17, 6, value3))
	bits32_3:add("ptrsTimeDensity: ", extractBits(23, 2, value3))
	bits32_3:add("ptrsReOffset: ", extractBits(25, 2, value3))
	bits32_3:add("nEpreRatioOfPDSCHToPTRS: ", extractBits(27, 2, value3))
	bits32_3:add("powerControlOffsetSS: ", extractBits(29, 2, value3))
	bits32_3:add("pad1: ", extractBits(31, 1, value3))
	
	local value4 = buffer(bufIdx[1], 4):le_uint()
	bufIdx[1] = bufIdx[1] + 4
	local bits32_4 = subtree:add(nfapi_p7_protocol, buffer(), "bits32_4  0x"..string.format("%x", value4))
	bits32_4:add("powerControlOffset: ", extractBits(0, 5, value4))
	bits32_4:add("targetCodeRateCw0: ", extractBits(5, 10, value4))
	bits32_4:add("targetCodeRateCw1: ", extractBits(15, 10, value4))
	bits32_4:add("pad: ", extractBits(25, 7, value4))
	
	for i = 0, 3 do
		subtree:add("layerId["..i.."]: ", buffer(bufIdx[1], 1):le_uint())
		bufIdx[1] = bufIdx[1] + 1
	end
	
	subtree:add("tbsLbrm: ", buffer(bufIdx[1], 4):le_uint())
end

function decode_pdsch_pdu_info_l2(subtree, buffer, bufIdx)
	local bwp = subtree:add(nfapi_p7_protocol, buffer(), "bwp")
	decode_bwp(bwp, buffer, bufIdx)
	local pdschPduInfo = subtree:add(nfapi_p7_protocol, buffer(), "pdschPduInfo")
	decode_pdsch_pdu_info(pdschPduInfo, buffer, bufIdx)
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
function decode_pdu_info(subtree, buffer, bufIdx)
	subtree:add("pduLength: ", buffer(bufIdx[1], 4):le_uint())
	bufIdx[1] = bufIdx[1] + 4
	subtree:add("pduIndex: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("pad: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	local numTlv = buffer(bufIdx[1], 4):le_uint()
	subtree:add("numTlv: ", buffer(bufIdx[1], 4):le_uint())
	bufIdx[1] = bufIdx[1] + 4
	
	for i = 0, numTlv - 1 do
		local tlv = subtree:add(nfapi_p7_protocol, buffer(), "tlv["..i.."]")
		tlv:add("tag: ", buffer(bufIdx[1], 2):le_uint())
		bufIdx[1] = bufIdx[1] + 2
		tlv:add("pad: ", buffer(bufIdx[1], 2):le_uint())
		bufIdx[1] = bufIdx[1] + 2
		local length = buffer(bufIdx[1], 2):le_uint()
		tlv:add("len: ", buffer(bufIdx[1], 2):le_uint())
		bufIdx[1] = bufIdx[1] + 2
		
		for j = 0, length - 1 do
			tlv:add("value["..j.."]: ", buffer(bufIdx[1], 1):le_uint())
			bufIdx[1] = bufIdx[1] + 1
		end
		
		local pad_len = ( 4 - ( length % 4 ) )
		
		for j = 0, pad_len - 1 do
			tlv:add("pad["..j.."]: ", buffer(bufIdx[1], 1):le_uint())
			bufIdx[1] = bufIdx[1] + 1
		end
	end
	
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
function decode_ssb_pbch_info(subtree, buffer, bufIdx)
	subtree:add("ssbPbchInfo: " .. string.format("%x", buffer(bufIdx[1], 4):le_uint()))
	bufIdx[1] = bufIdx[1] + 4
end

function decode_mib_info(subtree, buffer, bufIdx)
	subtree:add("dmrsTypeAPosition: ", buffer(bufIdx[1], 1))
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("pdcchConfigSib1: ", buffer(bufIdx[1], 1))
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("cellBarred: ", buffer(bufIdx[1], 1))
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("intraFreqReselection: ", buffer(bufIdx[1], 1))
	bufIdx[1] = bufIdx[1] + 1
end

function decode_bchPayload(subtree, buffer, bufIdx)
	local ssbPbchInfo = subtree:add(nfapi_p7_protocol, buffer(), "ssbPbchInfo")
	decode_ssb_pbch_info(ssbPbchInfo, buffer, bufIdx)
	local mibInfo = subtree:add(nfapi_p7_protocol, buffer(), "mibInfo")
	decode_mib_info(mibInfo, buffer, bufIdx)
end

function decode_ssb_pdu_info(subtree, buffer, bufIdx)
	subtree:add("physCellId: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("betaPss: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("ssbBlockIndex: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("ssbOffsetPointA: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("ssbSubcarrierOffset: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("bchPayloadFlag: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	
	local bchPayload = subtree:add(nfapi_p7_protocol, buffer(), "bchPayload")
	decode_bchPayload(bchPayload, buffer, bufIdx)
end

function decode_csi_rs_pdu_info(subtree, buffer, bufIdx)
	local value1 = buffer(bufIdx[1], 4):le_uint()
	bufIdx[1] = bufIdx[1] + 4
	local bits32_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits32_1  0x"..string.format("%x", value1))
	bits32_1:add("bwpIdx: ", extractBits(0, 8, value1))
	bits32_1:add("startRB: ", extractBits(8, 9, value1))
	bits32_1:add("nrOfRBs: ", extractBits(17, 9, value1))
	bits32_1:add("csiType: ", extractBits(26, 2, value1))
	bits32_1:add("symbL1: ", extractBits(28, 4, value1))
	
	local value2 = buffer(bufIdx[1], 4):le_uint()
	bufIdx[1] = bufIdx[1] + 4
	local bits32_2 = subtree:add(nfapi_p7_protocol, buffer(), "bits32_2  0x"..string.format("%x", value2))
	bits32_2:add("row: ", extractBits(0, 5, value2))
	bits32_2:add("freqDomain: ", extractBits(5, 12, value2))
	bits32_2:add("symbL0: ", extractBits(17, 4, value2))
	bits32_2:add("cdmType: ", extractBits(21, 2, value2))
	bits32_2:add("freqDensity: ", extractBits(23, 2, value2))
	bits32_2:add("powerControlOffset: ", extractBits(25, 5, value2))
	bits32_2:add("powerControlOffsetSS: ", extractBits(30, 2, value2))
	
	local value3 = buffer(bufIdx[1], 4):le_uint()
	bufIdx[1] = bufIdx[1] + 4
	local bits32_3 = subtree:add(nfapi_p7_protocol, buffer(), "bits32_3  0x"..string.format("%x", value3))
	bits32_3:add("scrambId: ", extractBits(0, 10, value1))
	bits32_3:add("pad: ", extractBits(10, 22, value1))
end

function decode_ssc_csi_dl_tti_req(subtree, buffer, bufIdx)
	decode_slot_info(subtree, buffer, bufIdx)
	subtree:add("numSsbPdu: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	local nCsiRsPdus = buffer(bufIdx[1], 1):le_uint()
	subtree:add("nCsiRsPdus: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	for i = 0, 1 do
		tlv:add("pad["..i.."]: ", buffer(bufIdx[1], 1):le_uint())
		bufIdx[1] = bufIdx[1] + 1
	end
	for i = 0, 1 do
		local ssbPduInfo = subtree:add(nfapi_p7_protocol, buffer(), "ssbPduInfo["..i.."]")
		decode_ssb_pdu_info(ssbPduInfo, buffer, bufIdx)
	end
	
	for i = 0, nCsiRsPdus - 1 do
		local csiRsPduInfo = subtree:add(nfapi_p7_protocol, buffer(), "csiRsPduInfo["..i.."]")
		decode_csi_rs_pdu_info(csiRsPduInfo, buffer, bufIdx)
	end
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
function decode_prach_pdu_info(subtree, buffer, bufIdx)
	local value = buffer(bufIdx[1], 2):le_uint()
	local bits16_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits16_1  0x"..string.format("%x", value))
	bufIdx[1] = bufIdx[1] + 2
	bits16_1:add("physCellID: ", extractBits(0, 10, value))
	bits16_1:add("numPuschSlot: ", extractBits(10, 6, value))
	
	subtree:add("NumPrachOcas: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("prachFormat: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("numRa: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("prachStartSymbol: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("numCs: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
function decode_nr_ldpc_tb_params(subtree, buffer, bufIdx)
	local value1 = buffer(bufIdx[1], 4):le_uint()
	bufIdx[1] = bufIdx[1] + 4
	local bits32_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits32_1  0x"..string.format("%x", value1))
	bits32_1:add("num_cb: ", extractBits(0, 8, value1))
	bits32_1:add("code_id: ", extractBits(8, 8, value1))
	bits32_1:add("cb_crc_select: ", extractBits(16, 1, value1))
	bits32_1:add("cbLen: ", extractBits(17, 15, value1))
	
	local value2 = buffer(bufIdx[1], 4):le_uint()
	bufIdx[1] = bufIdx[1] + 4
	local bits32_2 = subtree:add(nfapi_p7_protocol, buffer(), "bits32_2  0x"..string.format("%x", value2))
	bits32_2:add("k0: ", extractBits(0, 16, value2))
	bits32_2:add("Ncb: ", extractBits(16, 16, value2))
	
	local value3 = buffer(bufIdx[1], 4):le_uint()
	bufIdx[1] = bufIdx[1] + 4
	local bits32_3 = subtree:add(nfapi_p7_protocol, buffer(), "bits32_3  0x"..string.format("%x", value3))
	bits32_3:add("nfiller: ", extractBits(0, 16, value3))
	bits32_3:add("K: ", extractBits(16, 16, value3))
end

function decode_pusch_pdu(subtree, buffer, bufIdx)
	subtree:add("rnti: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("targetCodeRate: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("dataScramblingId: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("ulDmrsSymbPos: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("ulDmrsScramblingId: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("scid: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("bwpIdx: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	
	local value1 = buffer(bufIdx[1], 4):le_uint()
	bufIdx[1] = bufIdx[1] + 4
	local bits32_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits32_1  0x"..string.format("%x", value1))
	bits32_1:add("pduBitmap: ", extractBits(0, 2, value1))
	bits32_1:add("qamModOrder: ", extractBits(2, 4, value1))
	bits32_1:add("transformPrecoding: ", extractBits(6, 1, value1))
	bits32_1:add("nrOfLayers: ", extractBits(7, 3, value1))
	bits32_1:add("dmrsConfigType: ", extractBits(10, 1, value1))
	bits32_1:add("numDmrsCdmGrpsNoData: ", extractBits(11, 2, value1))
	bits32_1:add("dmrsPorts: ", extractBits(13, 12, value1))
	bits32_1:add("resourceAlloc: ", extractBits(25, 1, value1))
	bits32_1:add("vrbtoPrbMapping: ", extractBits(26, 1, value1))
	bits32_1:add("uplinkFrequencyShift7p5khz: ", extractBits(27, 1, value1))
	bits32_1:add("startSymbolIndex: ", extractBits(28, 4, value1))
	
	for i = 0, 35 do
		subtree:add("rbBitmap["..i.."]: ", buffer(bufIdx[1], 1):le_uint())
		bufIdx[1] = bufIdx[1] + 1
	end
	
	local value2 = buffer(bufIdx[1], 4):le_uint()
	bufIdx[1] = bufIdx[1] + 4
	local bits32_2 = subtree:add(nfapi_p7_protocol, buffer(), "bits32_2  0x"..string.format("%x", value2))
	bits32_2:add("rbStart: ", extractBits(0, 9, value2))
	bits32_2:add("rbSize: ", extractBits(9, 9, value2))
	bits32_2:add("txDirectCurrentLocation: ", extractBits(18, 12, value2))
	bits32_2:add("alphaScaling: ", extractBits(30, 2, value2))
	
	local value3 = buffer(bufIdx[1], 4):le_uint()
	bufIdx[1] = bufIdx[1] + 4
	local bits32_3 = subtree:add(nfapi_p7_protocol, buffer(), "bits32_3  0x"..string.format("%x", value3))
	bits32_3:add("csiPart1BitLength: ", extractBits(0, 7, value3))
	bits32_3:add("csiPart2BitLength: ", extractBits(7, 7, value3))
	bits32_3:add("betaOffsetCsi1: ", extractBits(14, 5, value3))
	bits32_3:add("betaOffsetCsi2: ", extractBits(19, 5, value3))
	bits32_3:add("betaOffsetHarqAck: ", extractBits(24, 4, value3))
	bits32_3:add("nrOfSymbols: ", extractBits(28, 4, value3))
	
	local value4 = buffer(bufIdx[1], 4):le_uint()
	bufIdx[1] = bufIdx[1] + 4
	local bits32_4 = subtree:add(nfapi_p7_protocol, buffer(), "bits32_4  0x"..string.format("%x", value4))
	bits32_4:add("harqAckBitLength: ", extractBits(0, 5, value4))
	bits32_4:add("numCb: ", extractBits(5, 8, value4))
	bits32_4:add("rvIndex: ", extractBits(13, 2, value4))
	bits32_4:add("harqProcessID: ", extractBits(15, 4, value4))
	bits32_4:add("newDataIndicator: ", extractBits(19, 1, value4))
	bits32_4:add("pad2: ", extractBits(20, 12, value4))
	
	for i = 0, MAX_CB_POS_LEN - 1 do
		subtree:add("cbPresentAndPosition["..i.."]: ", buffer(bufIdx[1], 1):le_uint())
		bufIdx[1] = bufIdx[1] + 1
	end
	
	subtree:add("---padding(1bytes)---")
	bufIdx[1] = bufIdx[1] + 1
	
	subtree:add("tbSize: ", buffer(bufIdx[1], 4):le_uint())
	bufIdx[1] = bufIdx[1] + 4
	
	local value5 = buffer(bufIdx[1], 4):le_uint()
	bufIdx[1] = bufIdx[1] + 4
	local bits32_5 = subtree:add(nfapi_p7_protocol, buffer(), "bits32_4  0x"..string.format("%x", value5))
	bits32_5:add("hqBuff128MBPageAddrTblIdx: ", extractBits(0, 4, value5))
	bits32_5:add("hqBuff128MBPageOffset: ", extractBits(4, 28, value5))
	
	subtree:add("hqBuffSize: ", buffer(bufIdx[1], 4):le_uint())
	bufIdx[1] = bufIdx[1] + 4
	
	local nrLdpcTbParams = subtree:add(nfapi_p7_protocol, buffer(), "nrLdpcTbParams")
	decode_nr_ldpc_tb_params(nrLdpcTbParams, buffer, bufIdx)
end

function decode_pusch_pdu_l2(subtree, buffer, bufIdx)
	subtree:add("handle: ", buffer(bufIdx[1], 4):le_uint())
	local bwp = subtree:add(nfapi_p7_protocol, buffer(), "bwp")
	decode_bwp(bwp, buffer, bufIdx)
	local puschPdu = subtree:add(nfapi_p7_protocol, buffer(), "puschPdu")
	decode_pusch_pdu(puschPdu, buffer, bufIdx)
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
function decode_pucch_pdu(subtree, buffer, bufIdx)
	subtree:add("rnti: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("dmrsScramblingId: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("dataScramblingId: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("bwpIdx: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("pad: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	
	local value1 = buffer(bufIdx[1], 4):le_uint()
	bufIdx[1] = bufIdx[1] + 4
	local bits32_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits32_1  0x"..string.format("%x", value1))
	bits32_1:add("formatType: ", extractBits(0, 3, value1))
	bits32_1:add("multiSlotTxIndicator: ", extractBits(3, 2, value1))
	bits32_1:add("pi2Bpsk: ", extractBits(5, 1, value1))
	bits32_1:add("startSymbolIndex: ", extractBits(6, 4, value1))
	bits32_1:add("prbStart: ", extractBits(10, 9, value1))
	bits32_1:add("prbSize: ", extractBits(19, 5, value1))
	bits32_1:add("timeDomainOccIdx: ", extractBits(24, 3, value1))
	bits32_1:add("preDftOccIdx: ", extractBits(27, 2, value1))
	bits32_1:add("preDftOccLen: ", extractBits(29, 3, value1))
	
	local value2 = buffer(bufIdx[1], 4):le_uint()
	bufIdx[1] = bufIdx[1] + 4
	local bits32_2 = subtree:add(nfapi_p7_protocol, buffer(), "bits32_2  0x"..string.format("%x", value2))
	bits32_2:add("addDmrsFlag: ", extractBits(0, 1, value2))
	bits32_2:add("dmrsCyclicshift: ", extractBits(1, 4, value2))
	bits32_2:add("nrOfSymbols: ", extractBits(5, 4, value2))
	bits32_2:add("srFlag1: ", extractBits(9, 1, value2))
	bits32_2:add("bitLenHarq: ", extractBits(10, 5, value2))
	bits32_2:add("bitLenCsiPart1: ", extractBits(15, 7, value2))
	bits32_2:add("bitLenCsiPart2: ", extractBits(22, 7, value2))
	bits32_2:add("freqHopFlag: ", extractBits(29, 1, value2))
	bits32_2:add("pad2: ", extractBits(30, 2, value2))
	
end

function decode_pucch_pdu_l2(pucchPduL2, buffer, bufIdx)
	subtree:add("handle: ", buffer(bufIdx[1], 4):le_uint())
	local bwp = subtree:add(nfapi_p7_protocol, buffer(), "bwp")
	decode_bwp(bwp, buffer, bufIdx)
	local pucchPdu = subtree:add(nfapi_p7_protocol, buffer(), "pucchPdu")
	decode_pucch_pdu(pucchPdu, buffer, bufIdx)
end
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
function decode_prg_alloc_info(subtree, buffer, bufIdx)
	subtree:add("PMIdx: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	
	local value1 = buffer(bufIdx[1], 1):le_uint()
	bufIdx[1] = bufIdx[1] + 1
	local bits8_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits8_1  0x"..string.format("%x", value1))
	bits8_1:add("startSymbol: ", extractBits(0, 4, value1))
	bits8_1:add("numSymbol: ", extractBits(4, 4, value1))
	
	subtree:add("resvd: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
end

function decode_tx_prec_and_bf(subtree, buffer, bufIdx)
	subtree:add("numAlloc: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	
	for i = 0, 2 do
		subtree:add("resvd: ", buffer(bufIdx[1], 1):le_uint())
		bufIdx[1] = bufIdx[1] + 1
	end
	
	for i = 0, FTL_MAX_NUM_ALLOC_IN_PRG - 1 do
		local prgAllocInfo = subtree:add(nfapi_p7_protocol, buffer(), "prgAllocInfo["..i.."]")
		decode_prg_alloc_info(prgAllocInfo, buffer, bufIdx)
	end
	
end

function decode_tx_prec_add_bf_info(subtree, buffer, bufIdx)
	for i = 0, FTL_MAX_RB - 1 do
		local txPrecAndBf = subtree:add(nfapi_p7_protocol, buffer(), "txPrecAndBf["..i.."]")
		decode_tx_prec_and_bf(txPrecAndBf, buffer, bufIdx)
	end
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
function decode_ul_pdu_info(subtree, buffer, bufIdx)
	subtree:add("handle: ", buffer(bufIdx[1], 4):le_uint())
	bufIdx[1] = bufIdx[1] + 4
	subtree:add("rnti: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("harqID: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("ulCqi: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	local tbLen =  buffer(bufIdx[1], 4):le_uint()
	subtree:add("tbLen: ", tbLen)
	bufIdx[1] = bufIdx[1] + 4
	subtree:add("ta: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("rssi: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	
	for i = 0, tbLen - 1 do
		subtree:add("payload: ", buffer(bufIdx[1], 1):le_uint())
		bufIdx[1] = bufIdx[1] + 1
	end	
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
function decode_crc_pdu(subtree, buffer, bufIdx)
	subtree:add("handle: ", buffer(bufIdx[1], 4):le_uint())
	bufIdx[1] = bufIdx[1] + 4
	subtree:add("rnti: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	
	local value1 = buffer(bufIdx[1], 2):le_uint()
	bufIdx[1] = bufIdx[1] + 2
	local bits16_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits16_1  0x"..string.format("%x", value1))
	bits16_1:add("harqId: ", extractBits(0, 4, value1))
	bits16_1:add("tbCrcStatus: ", extractBits(4, 1, value1))
	bits16_1:add("ulCqi2: ", extractBits(5, 8, value1))
	bits16_1:add("pad1: ", extractBits(13, 3, value1))
	
	subtree:add("ulCqi: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	
	local value2 = buffer(bufIdx[1], 1):le_uint()
	bufIdx[1] = bufIdx[1] + 1
	local bits8_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits8_1  0x"..string.format("%x", value2))
	bits8_1:add("timingAdvance: ", extractBits(0, 7, value2))
	bits8_1:add("pad2: ", extractBits(7, 1, value2))
	
	local value3 = buffer(bufIdx[1], 2):le_uint()
	bufIdx[1] = bufIdx[1] + 2
	local bits16_2 = subtree:add(nfapi_p7_protocol, buffer(), "bits16_2  0x"..string.format("%x", value3))
	bits16_2:add("rssi: ", extractBits(0, 11, value3))
	bits16_2:add("pad3: ", extractBits(11, 5, value3))
	
	subtree:add("numCb: ", buffer(bufIdx[1], 1))
	bufIdx[1] = bufIdx[1] + 1
	
	for i = 0, MAX_CB_POS_LEN - 1 do
		subtree:add("cbCrcStatus["..i.."]: ", buffer(bufIdx[1], 1):le_uint())
		bufIdx[1] = bufIdx[1] + 1
		
	end
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
function decode_pre_info(subtree, buffer, bufIdx)
	subtree:add("preambleIndex: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("pad: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("timingAdvance: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("preamblePwr: ", buffer(bufIdx[1], 4):le_uint())
	bufIdx[1] = bufIdx[1] + 4
end

function decode_rach_ind(subtree, buffer, bufIdx)
	subtree:add("physCellID: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	subtree:add("symbolIndex: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("slotIndex: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("freqIndex: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("avgRssi: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("avgSnr: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	subtree:add("numPreamble: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	
	for i = 0, MAX_NUM_PREAMBLE_CARRIER - 1 do
		local preInfo = subtree:add(nfapi_p7_protocol, buffer(), "preInfo["..i.."]")
		decode_pre_info(preInfo, buffer, bufIdx)
	end
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
function decode_hard_info(subtree, buffer, bufIdx)
	local value1 = buffer(bufIdx[1], 1):le_uint()
	bufIdx[1] = bufIdx[1] + 1
	local bits8_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits8_1  0x"..string.format("%x", value1))
	bits8_1:add("numHarq: ", extractBits(0, 2, value1))
	bits8_1:add("harqConfidenceLevel: ", extractBits(2, 2, value1))
	bits8_1:add("harqValue0: ", extractBits(4, 2, value1))
	bits8_1:add("harqValue1: ", extractBits(6, 2, value1))
	
	local value2 = buffer(bufIdx[1], 1):le_uint()
	bufIdx[1] = bufIdx[1] + 1
	local bits8_2 = subtree:add(nfapi_p7_protocol, buffer(), "bits8_2  0x"..string.format("%x", value2))
	bits8_2:add("isValid: ", extractBits(0, 1, value2))
	bits8_2:add("resvd1: ", extractBits(1, 7, value2))
end

function decode_pucch_01_uci_pdu(pucch01UciPdu, buffer, bufIdx)
	subtree:add("handle: ", buffer(bufIdx[1], 4):le_uint())
	bufIdx[1] = bufIdx[1] + 4
	subtree:add("rnti: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	
	local value1 = buffer(bufIdx[1], 2):le_uint()
	bufIdx[1] = bufIdx[1] + 2
	local bits16_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits16_1  0x"..string.format("%x", value1))
	bits16_1:add("pduBitMap: ", extractBits(0, 2, value1))
	bits16_1:add("pucchFormat: ", extractBits(2, 1, value1))
	bits16_1:add("resvd1: ", extractBits(3, 13, value1))
	
	subtree:add("ulCqi: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	
	local value2 = buffer(bufIdx[1], 1):le_uint()
	bufIdx[1] = bufIdx[1] + 1
	local bits8_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits8_1  0x"..string.format("%x", value2))
	bits8_1:add("timingAdvance: ", extractBits(0, 7, value2))
	bits8_1:add("isSrValid: ", extractBits(7, 1, value2))
	
	local value3 = buffer(bufIdx[1], 2):le_uint()
	bufIdx[1] = bufIdx[1] + 2
	local bits16_2 = subtree:add(nfapi_p7_protocol, buffer(), "bits16_2  0x"..string.format("%x", value3))
	bits16_2:add("rssi: ", extractBits(0, 11, value3))
	bits16_2:add("srIndication: ", extractBits(11, 1, value3))
	bits16_2:add("srConfidenceLevel: ", extractBits(12, 2, value3))
	bits16_2:add("resvd3: ", extractBits(14, 2, value3))
	
	local harqInfo = subtree:add(nfapi_p7_protocol, buffer(), "harqInfo")
	decode_hard_info(harqInfo, buffer, bufIdx)
	
	subtree:add("resvd5: ", buffer(bufIdx[1], 2):le_int())
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
function decode_sr_info(subtree, buffer, bufIdx)
	local value1 = buffer(bufIdx[1], 1):le_uint()
	bufIdx[1] = bufIdx[1] + 1
	local bits8_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits8_1  0x"..string.format("%x", value1))
	bits8_1:add("srBitLen: ", extractBits(0, 4, value1))
	bits8_1:add("isValid: ", extractBits(4, 1, value1))
	bits8_1:add("pad: ", extractBits(5, 3, value1))
	
	subtree:add("srPayload: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
end

function decode_hard_pucch_234(subtree, buffer, bufIdx)
	local value1 = buffer(bufIdx[1], 1):le_uint()
	bufIdx[1] = bufIdx[1] + 1
	local bits8_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits8_1  0x"..string.format("%x", value1))
	bits8_1:add("harqCrc: ", extractBits(0, 2, value1))
	bits8_1:add("harqBitLen: ", extractBits(2, 5, value1))
	bits8_1:add("isValid: ", extractBits(7, 1, value1))
	
	for i = 0, MAX_HARQ_BIT_LEN - 1 do
		subtree:add("harqPayload["..i.."]", buffer(bufIdx[1], 1):le_uint())
		bufIdx[1] = bufIdx[1] + 1
	end
end

function decode_csi_part1(subtree, buffer, bufIdx)
	local value1 = buffer(bufIdx[1], 2):le_uint()
	bufIdx[1] = bufIdx[1] + 2
	local bits16_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits16_1  0x"..string.format("%x", value1))
	bits16_1:add("csiPart1Crc: ", extractBits(0, 2, value1))
	bits16_1:add("csiPart1BitLen: ", extractBits(2, 7, value1))
	bits16_1:add("isValid: ", extractBits(9, 1, value1))
	bits16_1:add("pad: ", extractBits(10, 6, value1))
	
	for i = 0, MAX_CSI_PART1BIT_LEN - 1 do
		subtree:add("csiPart1Payload["..i.."]: ", buffer(bufIdx[1], 1):le_uint())
		bufIdx[1] = bufIdx[1] + 1
	end
end

function decode_csi_part2(subtree, buffer, bufIdx)
	local value1 = buffer(bufIdx[1], 2):le_uint()
	bufIdx[1] = bufIdx[1] + 2
	local bits16_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits16_1  0x"..string.format("%x", value1))
	bits16_1:add("csiPart2Crc: ", extractBits(0, 2, value1))
	bits16_1:add("csiPart2BitLen: ", extractBits(2, 7, value1))
	bits16_1:add("isValid: ", extractBits(9, 1, value1))
	bits16_1:add("pad: ", extractBits(10, 6, value1))
	
	for i = 0, MAX_CSI_PART2BIT_LEN - 1 do
		subtree:add("csiPart2Payload["..i.."]: ", buffer(bufIdx[1], 1):le_uint())
		bufIdx[1] = bufIdx[1] + 1
	end
end

function decode_pucch_234_uci_pdu(subtree, buffer, bufIdx)
	subtree:add("handle: ", buffer(bufIdx[1], 4):le_uint())
	bufIdx[1] = bufIdx[1] + 4
	subtree:add("rnti: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	
	local value1 = buffer(bufIdx[1], 2):le_uint()
	bufIdx[1] = bufIdx[1] + 2
	local bits16_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits16_1  0x"..string.format("%x", value1))
	bits16_1:add("pduBitMap: ", extractBits(0, 4, value1))
	bits16_1:add("pucchFormat: ", extractBits(4, 2, value1))
	bits16_1:add("resvd1: ", extractBits(6, 10, value1))
	
	local value2 = buffer(bufIdx[1], 4):le_uint()
	bufIdx[1] = bufIdx[1] + 4
	local bits32_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits32_1  0x"..string.format("%x", value2))
	bits32_1:add("ulCqi: ", extractBits(0, 8, value2))
	bits32_1:add("timingAdvance: ", extractBits(8, 7, value2))
	bits32_1:add("resvd2: ", extractBits(15, 1, value2))
	bits32_1:add("rssi: ", extractBits(16, 11, value2))
	bits32_1:add("resvd3: ", extractBits(27, 5, value2))
	
	local srInfo = subtree:add(nfapi_p7_protocol, buffer(), "srInfo")
	decode_sr_info(srInfo, buffer, bufIdx)
	
	subtree:add("resvd4: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	
	local harqInfo = subtree:add(nfapi_p7_protocol, buffer(), "harqInfo")
	decode_hard_pucch_234(harqInfo, buffer, bufIdx)
	
	local csiPart1 = subtree:add(nfapi_p7_protocol, buffer(), "csiPart1")
	decode_csi_part1(csiPart1, buffer, bufIdx)
	
	local csiPart2 = subtree:add(nfapi_p7_protocol, buffer(), "csiPart2")
	decode_csi_part2(csiPart2, buffer, bufIdx)
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
function decode_pusch_uci_pdu(subtree, buffer, bufIdx)
	subtree:add("handle: ", buffer(bufIdx[1], 4):le_uint())
	bufIdx[1] = bufIdx[1] + 4
	subtree:add("rnti: ", buffer(bufIdx[1], 2):le_uint())
	bufIdx[1] = bufIdx[1] + 2
	
	local value1 = buffer(bufIdx[1], 2):le_uint()
	bufIdx[1] = bufIdx[1] + 2
	local bits16_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits16_1  0x"..string.format("%x", value1))
	bits16_1:add("pduBitMap: ", extractBits(0, 4, value1))
	bits16_1:add("resvd1: ", extractBits(4, 12, value1))
	
	subtree:add("ulCqi: ", buffer(bufIdx[1], 1):le_uint())
	bufIdx[1] = bufIdx[1] + 1
	
	local value2 = buffer(bufIdx[1], 1):le_uint()
	bufIdx[1] = bufIdx[1] + 1
	local bits8_1 = subtree:add(nfapi_p7_protocol, buffer(), "bits8_1  0x"..string.format("%x", value2))
	bits8_1:add("timingAdvance: ", extractBits(0, 7, value2))
	bits8_1:add("resvd2: ", extractBits(7, 1, value2))
	
	local value3 = buffer(bufIdx[1], 2):le_uint()
	bufIdx[1] = bufIdx[1] + 2
	local bits16_2 = subtree:add(nfapi_p7_protocol, buffer(), "bits16_2  0x"..string.format("%x", value3))
	bits16_2:add("rssi: ", extractBits(0, 4, value3))
	bits16_2:add("resvd3: ", extractBits(4, 12, value3))
	
	local harqInfo = subtree:add(nfapi_p7_protocol, buffer(), "harqInfo")
	decode_hard_pucch_234(harqInfo, buffer, bufIdx)
	
	local csiPart1 = subtree:add(nfapi_p7_protocol, buffer(), "csiPart1")
	decode_csi_part1(csiPart1, buffer, bufIdx)
	
	local csiPart2 = subtree:add(nfapi_p7_protocol, buffer(), "csiPart2")
	decode_csi_part2(csiPart2, buffer, bufIdx)
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
function nfapi_p7_protocol.dissector(buffer, pinfo, tree)
	length = buffer:len()
	if length == 0 then return end

	pinfo.cols.protocol = nfapi_protocol.name

	local subtree = tree:add(nfapi_p7_protocol, buffer(), "nFAPI P7 Protocol Data")
	local nfapihdrSubtree = subtree:add(nfapi_p7_protocol, buffer(), "nFAPI P7 Header")
	
	local bufIdx = {0}
	decode_nfapi_hdr(nfapihdrSubtree, buffer, bufIdx)
	
	local msgHdrSubtree = subtree:add(nfapi_p7_protocol, buffer(), "msg Header")
	local msgType = decode_msg_hdr(msgHdrSubtree, buffer, bufIdx)
	
	-- Set the Info column text to the message type name
    pinfo.cols.info = msgType
	local body = subtree:add(nfapi_p7_protocol, buffer(), "msg Body")
	
	if msgType == "NFAPI_P7_DL_NODE_SYNC" then
		body:add("t1: ", buffer(bufIdx[1], 4):uint())
		bufIdx[1] = bufIdx[1] + 4
		body:add("deltaSFNSlot: ", buffer(bufIdx[1], 4):int())
		bufIdx[1] = bufIdx[1] + 4
		body:add("subCarrierSpacing: ", buffer(bufIdx[1], 1):uint())
		bufIdx[1] = bufIdx[1] + 1
	elseif msgType == "NFAPI_P7_UL_NODE_SYNC" then
		body:add("t1: ", buffer(bufIdx[1], 4):uint())
		bufIdx[1] = bufIdx[1] + 4
		body:add("t2: ", buffer(bufIdx[1], 4):uint())
		bufIdx[1] = bufIdx[1] + 4
		body:add("t3: ", buffer(bufIdx[1], 4):uint())
		bufIdx[1] = bufIdx[1] + 4
	elseif msgType == "NFAPI_P7_TIMING_INFO" then
		body:add("lastSfn: ", buffer(bufIdx[1], 2):uint())
		bufIdx[1] = bufIdx[1] + 2
		body:add("lastSlot: ", buffer(bufIdx[1], 2):uint())
		bufIdx[1] = bufIdx[1] + 2
		body:add("lastTimingInfo: ", buffer(bufIdx[1], 4):uint())
		bufIdx[1] = bufIdx[1] + 4
		body:add("dlttiJitter: ", buffer(bufIdx[1], 4):uint())
		bufIdx[1] = bufIdx[1] + 4
		body:add("txDataJitter: ", buffer(bufIdx[1], 4):uint())
		bufIdx[1] = bufIdx[1] + 4
		body:add("ulttiJitter: ", buffer(bufIdx[1], 4):uint())
		bufIdx[1] = bufIdx[1] + 4
		body:add("uldciJitter: ", buffer(bufIdx[1], 4):uint())
		bufIdx[1] = bufIdx[1] + 4
		body:add("dlttiLatestDelay: ", buffer(bufIdx[1], 4):int())
		bufIdx[1] = bufIdx[1] + 4
		body:add("txdataLatestDelay: ", buffer(bufIdx[1], 4):int())
		bufIdx[1] = bufIdx[1] + 4
		body:add("ulttiLatestDelay: ", buffer(bufIdx[1], 4):int())
		bufIdx[1] = bufIdx[1] + 4
		body:add("uldciLatestDelay: ", buffer(bufIdx[1], 4):int())
		bufIdx[1] = bufIdx[1] + 4
		body:add("dlttiEarArrival: ", buffer(bufIdx[1], 4):int())
		bufIdx[1] = bufIdx[1] + 4
		body:add("txdatareqEarArrival: ", buffer(bufIdx[1], 4):int())
		bufIdx[1] = bufIdx[1] + 4
		body:add("ulttiEarArrival: ", buffer(bufIdx[1], 4):int())
		bufIdx[1] = bufIdx[1] + 4
		body:add("uldciEarArrival: ", buffer(bufIdx[1], 4):int())
		bufIdx[1] = bufIdx[1] + 4
		body:add("subcarrierSpacing: ", buffer(bufIdx[1], 1):uint())
		bufIdx[1] = bufIdx[1] + 1
	elseif msgType == "NFAPI_OUT_OF_SYNC" then
		body:add("sequenceNumber: ", buffer(bufIdx[1], 2):uint())
		bufIdx[1] = bufIdx[1] + 2
	elseif msgType == "P7_DL_TTI_REQUEST" then
	elseif msgType == "P7_UL_TTI_REQUEST" then
	elseif msgType == "P7_SLOT_INDICATION" then
		decode_slot_info(body, buffer, bufIdx)
	elseif msgType == "P7_UL_DCI_REQUEST" then
		decode_slot_info(body, buffer, bufIdx)
		decode_pdcch_pdu_info(body, buffer, bufIdx)
	elseif msgType == "P7_TX_DATA_REQUEST" then
		decode_slot_info(body, buffer, bufIdx)
		local numberDlPdu = buffer(bufIdx[1], 2):le_uint()
		body:add("numberDlPdu: ", buffer(bufIdx[1], 2):le_uint())
		bufIdx[1] = bufIdx[1] + 2
		body:add("---padding(2bytes)---")
		bufIdx[1] = bufIdx[1] + 2
		for i = 0, numberDlPdu - 1, 1 do
			local pduInfo = body:add(nfapi_p7_protocol, buffer(), "pduInfo["..i.."]")
			decode_pdu_info(pduInfo, buffer, bufIdx)
		end
	elseif msgType == "P7_RX_DATA_INDICATION" then
		decode_slot_info(body, buffer, bufIdx)
		local numberUlPdu = buffer(bufIdx[1], 2):le_uint()
		bufIdx[1] = bufIdx[1] + 2
		body:add("numberUlPdu: ", numberUlPdu)
		body:add("---padding(2bytes)---")
		bufIdx[1] = bufIdx[1] + 2
		for i = 0, numberUlPdu - 1 do
			local pduInfo = body:add(nfapi_p7_protocol, buffer(), "pduInfo["..i.."]")
			decode_ul_pdu_info(pduInfo, buffer, bufIdx)
		end
	elseif msgType == "P7_CRC_INDICATION" then
		decode_slot_info(body, buffer, bufIdx)
		local NumCRCs = buffer(bufIdx[1], 1):le_uint()
		bufIdx[1] = bufIdx[1] + 1
		body:add("NumCRCs: ", NumCRCs)
		body:add("---padding(3bytes)---")
		bufIdx[1] = bufIdx[1] + 3
		for i = 0, NumCRCs - 1 do
			local crcPdu = body:add(nfapi_p7_protocol, buffer(), "crcPdu["..i.."]")
			decode_crc_pdu(crcPdu, buffer, bufIdx)
		end
	elseif msgType == "P7_UCI_INDICATION" then
	elseif msgType == "P7_SRS_INDICATION" then
	elseif msgType == "P7_RACH_INDICATION" then
		decode_slot_info(body, buffer, bufIdx)
		local rachInd = body:add(nfapi_p7_protocol, buffer(), "rachInd")
		decode_rach_ind(rachInd, buffer, bufIdx)
	elseif msgType == "P7_PDCCH_DL_TTI_REQUEST" then
		decode_slot_info(body, buffer, bufIdx)
		decode_pdcch_pdu_info(body, buffer, bufIdx)
	elseif msgType == "P7_PDSCH_DL_TTI_REQUEST" then
		decode_slot_info(body, buffer, bufIdx)
		local nPdschPdus = buffer(bufIdx[1], 1):le_uint()
		body:add("nPdschPdus: ", buffer(bufIdx[1], 1):le_uint())
		bufIdx[1] = bufIdx[1] + 1
		body:add("---padding(3bytes)---")
		bufIdx[1] = bufIdx[1] + 3
		for i = 0, nPdschPdus - 1, 1 do
			local pdschPduInfoL2 = body:add(nfapi_p7_protocol, buffer(), "pdschPduInfoL2["..i.."]")
			decode_pdsch_pdu_info_l2(pdschPduInfoL2, buffer, bufIdx)
		end
	elseif msgType == "P7_SSB_CSIRS_DL_TTI_REQUEST" then	
		decode_slot_info(body, buffer, bufIdx)
		local bwp = body:add(nfapi_p7_protocol, buffer(), "bwp")
		decode_bwp(bwp, buffer, bufIdx)
		local ssbCsiDlTtiReqPdu = body:add(nfapi_p7_protocol, buffer(), "ssbCsiDlTtiReqPdu")
		decode_ssc_csi_dl_tti_req(ssbCsiDlTtiReqPdu, buffer, bufIdx)
	elseif msgType == "P7_PUSCH_UL_TTI_REQUEST" then	
		decode_slot_info(body, buffer, bufIdx)
		for i = 0, 1 do
			local prachPduInfo = body:add(nfapi_p7_protocol, buffer(), "prachPduInfo["..i.."]")
			decode_prach_pdu_info(prachPduInfo, buffer, bufIdx)
		end
		body:add("nPrachPdu", buffer(bufIdx[1], 1):le_uint())
		bufIdx[1] = bufIdx[1] + 1
		local nULSCH = buffer(bufIdx[1], 1):le_uint()
		body:add("nULSCH", buffer(bufIdx[1], 1):le_uint())
		bufIdx[1] = bufIdx[1] + 1
		for i = 0, nULSCH - 1 do
			local puschPduL2 = body:add(nfapi_p7_protocol, buffer(), "puschPduL2["..i.."]")
			decode_pusch_pdu_l2(puschPduL2, buffer, bufIdx)
		end
	elseif msgType == "P7_PUCCH_UL_TTI_REQUEST" then
		decode_slot_info(body, buffer, bufIdx)
		local nULCCH = buffer(bufIdx[1], 2):le_uint();
		body:add("nULCCH: ", nULCCH)
		bufIdx[1] = bufIdx[1] + 2
		for i = 0, nULCCH - 1 do
			local pucchPduL2 = body:add(nfapi_p7_protocol, buffer(), "pucchPduL2["..i.."]")
			decode_pucch_pdu_l2(pucchPduL2, buffer, bufIdx)
		end
	elseif msgType == "P7_PUCCH_UCI01_INDICATION" then	
		decode_slot_info(body, buffer, bufIdx)
		local numPucch01Uci = buffer(bufIdx[1], 2):le_uint()
		bufIdx[1] = bufIdx[1] + 2
		body:add("numPucch01Uci: ", numPucch01Uci)
		bufIdx[1] = bufIdx[1] + 2
		body:add("---padding(2bytes)---")
		for i = 0, numPucch01Uci - 1 do
			local pucch01UciPdu = body:add(nfapi_p7_protocol, buffer(), "pucch01UciPdu["..i.."]")
			decode_pucch_01_uci_pdu(pucch01UciPdu, buffer, bufIdx)
		end
	elseif msgType == "P7_PUCCH_UCI234_INDICATION" then	
		decode_slot_info(body, buffer, bufIdx)
		local numPucch234Uci = buffer(bufIdx[1], 1):le_uint()
		bufIdx[1] = bufIdx[1] + 1
		body:add("numPucch234Uci: ", numPucch234Uci)
		body:add("---padding(3bytes)---")
		bufIdx[1] = bufIdx[1] + 3
		for i = 0, numPucch234Uci - 1 do
			local pucch234UciPdu = body:add(nfapi_p7_protocol, buffer(), "pucch234UciPdu["..i.."]")
			decode_pucch_234_uci_pdu(pucch234UciPdu, buffer, bufIdx)
		end
	elseif msgType == "P7_PUSCH_UCI_INDICATION" then	
		decode_slot_info(body, buffer, bufIdx)
		local numPuschUci = buffer(bufIdx[1], 1):le_uint()
		bufIdx[1] = bufIdx[1] + 1
		body:add("numPuschUci: ", numPuschUci)
		body:add("---padding(3bytes)---")
		bufIdx[1] = bufIdx[1] + 3
		for i = 0, numPuschUci - 1 do
			local puschUciPdu = body:add(nfapi_p7_protocol, buffer(), "puschUciPdu["..i.."]")
			decode_pusch_uci_pdu(puschUciPdu, buffer, bufIdx)
		end
	elseif msgType == "P7_SRS_UL_TTI_REQUEST" then	
	elseif msgType == "P7_PREC_MATRIX_TBL_CFG_REQ" then	
	elseif msgType == "P7_DIGITAL_BF_TBL_CFG_REQ" then	
	elseif msgType == "P7_DL_PREC_AND_BF_TTI_REQ" then
		decode_slot_info(body, buffer, bufIdx)
		body:add("numPRGs: ", buffer(bufIdx[1], 2):le_uint())
		bufIdx[1] = bufIdx[1] + 2
		body:add("resvd: ", buffer(bufIdx[1], 2):le_uint())
		bufIdx[1] = bufIdx[1] + 2
		local txPrecAndBfInfo = body:add(nfapi_p7_protocol, buffer(), "txPrecAndBfInfo")
		decode_tx_prec_add_bf_info(txPrecAndBfInfo, buffer, bufIdx)
	elseif msgType == "P7_UL_BF_TTI_REQ" then	
	elseif msgType == "P7_SRS_PWR_INDICATION" then	
	elseif msgType == "P7_SRS_BEAMFORM_INDICATION" then	
	end
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
local udp_port = DissectorTable.get("udp.port")
-- udp_port:add(8008, nfapi_p7_protocol)

-- Define the range of port numbers
local start_port = 8000
local end_port = 8010  -- Modify this to adjust the end of the range
-- Add the range of port numbers to the dissector table

for i = start_port, end_port do
	udp_port:add(i, nfapi_p7_protocol)
end

-- udp_port:add_range(start_port, end_port, nfapi_p7_protocol)