`timescale 1ns / 1ps
module ADC #(parameter IO_BITS = 12,
             SAMPLE_BITS = 12,
             TOGGLE_CHANNELS_STATE_BITS = 2,
             DRP_ADDRESS_BITS = 7,
             DRP_SAMPLE_BITS = 16)
            (input vauxp11,
             input vauxn11,
             input vauxp3,
             input vauxn3,
             input clk,
             input reset,
             input [5:0] samplePeriod,
             output adcc_ready,
             output adccRawReady,
             output signed [11:0] ADCCdataOutChannel1,
             output signed [11:0] adccRawDataOutChannel1,
             output signed [11:0] ADCCdataOutChannel2,
             output signed [11:0] adccRawDataOutChannel2);
    
    wire [TOGGLE_CHANNELS_STATE_BITS-1:0] state;
    wire [TOGGLE_CHANNELS_STATE_BITS-1:0] previousState;
    wire channelDataReady;
    wire [DRP_ADDRESS_BITS-1:0] DRPAddress;
    wire DRPEnable;
    wire DRPWriteEnable;
    wire DRPReady;
    wire signed [DRP_SAMPLE_BITS-1:0] DRPDataOut;
    wire endOfConversion;
    wire signed [SAMPLE_BITS-1:0] channel1;
    wire signed [SAMPLE_BITS-1:0] channel2;
    
    xadc_wiz_0 xadc (
    .di_in(),
    .daddr_in(DRPAddress),
    .den_in(DRPEnable),
    .dwe_in(DRPWriteEnable),
    .drdy_out(DRPReady),
    .do_out(DRPDataOut),
    .dclk_in(clk),
    .reset_in(reset),
    .vp_in(),
    .vn_in(),
    .vauxp3(vauxp3),
    .vauxn3(vauxn3),
    .vauxp11(vauxp11),
    .vauxn11(vauxn11),
    .channel_out(),
    .eoc_out(endOfConversion),
    .alarm_out(),
    .eos_out(),
    .busy_out()
    );
    
    ToggleChannels myToggleChannels(
    .clock(clk),
    .endOfConversion(endOfConversion),
    .DRPReady(DRPReady),
    .DRPDataOut(DRPDataOut[15:4]),
    .DRPEnable(DRPEnable),
    .DRPWriteEnable(DRPWriteEnable),
    .channel1(channel1),
    .channel2(channel2),
    .DRPAddress(DRPAddress),
    .channelDataReady(channelDataReady),
    .state(state),
    .previousState(previousState)
    );
    
    ADCcontroller adcc(
    .clock(clk),
    .reset(reset),
    .sampleEnabled(1),
    .inputReady(channelDataReady),
    .samplePeriod(samplePeriod),
    .ready(adcc_ready),
    .rawReady(adccRawReady),
    .dataInChannel1(channel1),
    .dataOutChannel1(ADCCdataOutChannel1),
    .rawDataOutChannel1(adccRawDataOutChannel1),
    .dataInChannel2(channel2),
    .dataOutChannel2(ADCCdataOutChannel2),
    .rawDataOutChannel2(adccRawDataOutChannel2)
    );
endmodule
