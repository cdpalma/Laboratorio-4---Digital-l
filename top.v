`include "./pulse.v"
`include "./pulse_width.v"
`include "./chronometer.v"

module top (
    // 12MHz clock input
    input  clk,
    input  echoPin,
    output triggerPin,
    output led
);

`ifdef DEBUG
  // Estas líneas están relacionadas al proceso de simulación
  localparam integer ClkFreq = 1000;  // 100 Ticks
  localparam real WidthPulse = 2e-3;  // 500 Ticks
  localparam integer LoopFreq = 3;  // 3 Hz
  localparam integer InitialPulseCnt = 0;
  localparam integer InitialPulseWidthCnt = 0;
  localparam integer SelectUnitChronometer = 100;  // 0 -> mS, 1 uS, 100 Ticks = FreqOfUnits
  localparam integer LimitTimer = 100;  // Ticks
  localparam integer LimitRecordTimer = 1000;  // Máxmimos ticks a contar
  localparam integer SizeWireTimer = $clog2(LimitRecordTimer);  // Tamaño del cable
`else
  // Estas líneas hacen referencia a los parametros de configuración en la síntesis
  localparam integer ClkFreq = 12000000;  // 12 Mhz
  localparam real WidthPulse = 11e-6;  // 11 uS
  localparam integer LoopFreq = 2;  // 2 Hz
  localparam integer InitialPulseCnt = 0;
  localparam integer InitialPulseWidthCnt = 0;
  localparam integer SelectUnitChronometer = 1;  // 0 -> mS, 1 uS, other = FreqOfUnits
  // Si velocidad del sonido V=340m/s en terminos de uS -> V = 34e-3 cm/uS
  // para 50 cm, -> tiempo = 50 cm / (34e-3 cm/uS) -> tiempo = 1471 uS
  // y como se trata del echo entonces tiempo x 2, por tanto
  // LimitTimer = 2942 uS
  localparam integer LimitTimer = 2941;  // uS
  localparam integer LimitRecordTimer = 15000;  // Máximo de uS a contar
  localparam integer SizeWireTimer = $clog2(LimitRecordTimer);  // Tamaño del cable
`endif

  wire start, busy_ultrasonic;
  wire [SizeWireTimer-1:0] timer;

  // Manejo de loop de lectura del sensor
  pulse #(
      .FREQ_IN(ClkFreq),
      .FREQ_OUT(LoopFreq),
      .INIT(InitialPulseCnt)
  ) loopSensor (
      .CLK_IN(clk),
      .PULSE_OUT(start)
  );

  // Manejo de disparo
  pulse_width #(
      .FREQ_IN(ClkFreq),
      .WIDTH_PULSE(WidthPulse),
      .INIT(InitialPulseWidthCnt)
  ) trigger_sensor (
      .clk(clk),
      .start(start),
      .signal(triggerPin)
  );

  // Manejo de eco
  chronometer #(
      .FREQ_IN(ClkFreq),
      .LIMIT_RECORD_TIMER(LimitRecordTimer),  // 15 mS -> 5.1 metros recorridos con echo
      .SELECT_UNITS(SelectUnitChronometer)
  ) echo_sensor (
      .clk(clk),
      .resetChronometer(start),
      .enableTimmerCounter(echoPin),
      .recordTimer(timer),
      .busy(busy_ultrasonic)
  );

  assign led = (timer != 0 && timer < LimitTimer && busy_ultrasonic == 0) ? 1 : 0;

endmodule
