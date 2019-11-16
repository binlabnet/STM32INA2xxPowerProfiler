unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin, ExtCtrls, Buttons, TeEngine, Series,
  TeeProcs, Chart, ArrowCha, TeeOpenGL, DB, TeeData, TeeGalleryPanel,
  TeeDraw3D, TeeEdit, TeeComma, TeCanvas, TeeStore, TeeSurfa, TeePoin3,
  TeeSeriesStats,  IniFiles;

const
    INA2XX_I2C_ADDR = $80;
    STM32_DEVICE_ID = $11;
    INA226_MID_REG = $fe;
    INA226_DID_REG = $ff;
    INA226_MID = $4954;
    INA226_DID = $6022;
    SMBus_Speed_kHz = 1000; // default

    CMD_GET_VER = $00; // Get Ver
    CMD_SET_INI = $01; // Get/Set CFG/ini & Start measure
    CMD_WRF_INI = $02; // Store CFG/ini in Flash
    CMD_GET_STA = $03; // Get status
    CMD_GET_REG = $10; // Get reg
    CMD_SET_REG = $11; // Set reg
    CMD_GET_DAA = $12; // Get SMBUS dev Alert addr
    RES_OUT_REGS = $07; // Send blk regs

    CHART_I_MASK  = 2;
    CHART_U_MASK  = 1;
    CHART_UI_MASK  = 3;

    CHART_U_NUM  = 0;
    CHART_I_NUM  = 1;

type
  xName = (xByte, xWord, xData);

 Tcfg_ini = packed record
   none   : dword;
 end;


type
  ina2xx_regs_t = packed record
   case xName of
    xWord: ( w : array[0..9] of word);
    xData: (
      config      : word;		// Configuration Register
      shunt       : Smallint;		// Shunt Voltage Register
      bus         : Smallint;		// Bus Voltage Register
      power       : word; 	// Power Register
      current     : word; 	// Current Register
      calibration : word; 	// Calibration Register
      mask_enable : word; 	// INA226: Mask/Enable Register, INA219: =0000
      alert_data  : word; 	// INA226: Alert Limit Register, INA219: =7E0A
      mid       : word;   // addr 0xfe: Manufacturer ID Register. INA226: =5449
      did       : word;   // addr 0xff: Die ID Register. INA226: =2260
    );
  end;

  ina2xx_rwr_t = packed record
      dev_addr    : byte;
      reg_addr    : byte;
      data        : word;
  end;
  ina2xx_rrd_t = packed record
      dev_addr    : byte;
      reg_addr    : byte;
  end;

  ina2xx_cfg_t = packed record
      rd_count    : byte; // ������� �a�� = ���-�� regs init, ������� = ���-�� regs ������
      wr_count    : byte; // ������� �a�� = ���-�� regs init, ������� = ���-�� regs ������
      time_us     : word;
      clk_khz     : word;
      init        : array [0..3] of ina2xx_rwr_t;
      data        : array [0..3] of ina2xx_rrd_t;
  end;

  TfrmMain = class(TForm)
    StatusBar: TStatusBar;
    Panel1: TPanel;
    btnQueryDosDevice: TButton;
    ComboBox: TComboBox;
    ButtonOpen: TButton;
    ButtonConfigReg: TButton;
    ButtonStart: TButton;
    ButtonStore: TButton;
    Panel2: TPanel;
    Timer1: TTimer;
    ButtonRdAllRegs: TButton;
    ButtonClrGrf: TButton;
    ButtonStop: TButton;
    Chart: TChart;
    ButtonSaveGRF: TButton;
    ButtonPrtGrf: TButton;
    PrintDialog: TPrintDialog;
    SaveDialog: TSaveDialog;
    PrinterSetupDialog: TPrinterSetupDialog;
    SetColorI: TLabel;
    SetColorU: TLabel;
    ColorDialog: TColorDialog;
    ButtonAsize: TButton;
    ButtonScalP: TButton;
    ButtonScalM: TButton;
    EditRegs: TEdit;
    TeeOpenGL1: TTeeOpenGL;
    ChartPreviewer: TChartPreviewer;
    TeeCommander: TTeeCommander;
    ChartTool1: TSeriesStatsTool;
    CheckBoxOpenGL: TCheckBox;
    Series2: TFastLineSeries;
    Series1: TFastLineSeries;
    EditSizeGrf: TEdit;
    EditUk: TEdit;
    EditIk: TEdit;
    EditTriggerI: TEdit;
    CheckBoxTrigerRiseI: TCheckBox;
    LabelMXI: TLabel;
    LabelMXU: TLabel;
    CheckBoxTrigerRiseU: TCheckBox;
    EditTriggerU: TEdit;
    procedure btnReScanComDevices(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ReScanComDevices;
    procedure ButtonOpenClick(Sender: TObject);
    function SetComName: boolean;
    procedure ChComName(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonConfigRegClick(Sender: TObject);
    procedure ButtonStoreClick(Sender: TObject);
    function GetDevVersion: boolean;

    function  IndexOfComName(const S: String): Integer;
    procedure TimerTimer(Sender: TObject);
    procedure ButtonRdAllRegsClick(Sender: TObject);
    procedure ButtonClrGrfClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure ButtonPrtGrfClick(Sender: TObject);
    procedure ButtonSaveGRFClick(Sender: TObject);

    procedure AddCrfSamples(count : integer);
    function GrfSetColor(ChNum : integer): integer;
    procedure ButtonAsizeClick(Sender: TObject);
    procedure ButtonScalMClick(Sender: TObject);
    procedure ButtonScalPClick(Sender: TObject);

    procedure ReadIni;
    procedure WriteIni;
    procedure GetScrParms;
    procedure ShowScrParms;
    procedure GetUIkParms;
    procedure ShowUIkParms;
    procedure ShowLabelsMX;
    procedure ShowSmps;
    procedure SetGrfMarging;
    procedure SetParStart;
    function ReadBlk(id : byte) : boolean;
    function SendBlk : boolean;
    function ReadStatus : boolean;
    function ReadGgfData : boolean;
    function ReadRegister(regnum : integer) : boolean;
    function ResetIna2xx : boolean;
    function RdAllRegs : boolean;
    function GetSmbusAlert : boolean;
    function GetDevIniCfg : boolean;
    function SetDevIniCfg(mode : integer) : boolean;
    function StopReadDevice: boolean;
    procedure ShowAllRegs;
    procedure ClearGrf;
//    procedure SpeedButton1Click(Sender: TObject);
    procedure CheckBoxOpenGLClick(Sender: TObject);
    procedure CheckBoxTrigerClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SetColorIMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SetColorUMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    flgValueChg : boolean;
    Ini_Cfg : Tcfg_ini;
    dev_id : byte;
    dev_ver: word;
    dev_not_send_count : dword;
    dev_all_send_count : dword;
    dev_send_err : byte;
    dev_alert_addr : byte;
    dev_ina226 : boolean;
    DeviceTypeRecognized : boolean;

    bufrx : array [0..63] of byte;
    lenrx : integer;
    wait_id : byte;
    wait_cnt : integer;

    buftx : array [0..63] of byte;

    TriggerI : Double;
    TriggerU : Double;
    TriggerUEnable : boolean;
    TriggerULow : boolean;
    TriggerIEnable : boolean;
    TriggerILow : boolean;

    SamplesCount : dword;
    MaxSamples: dword;
    SamplesEna : boolean;
    SamplesAutoStop : boolean;
    ConnectStartTime : TDateTime;
    bufsmp : array [0..63] of Smallint;
    ConnectTime : TDateTime;
    ChartEnables : byte;
    OldCurI, OldCurU: double;
    CurI, CurU: double;
    SumI, SumU: double;
    FormConfigOk : integer;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;
  ina2xx_reg : ina2xx_regs_t;
  blk_cfg : ina2xx_cfg_t;

  BuildInfoString: string;

  Uk : double;
  Ik : double;
  I_zero : double;
  U_zero : double;
  OldsI, OldsU: double;
  
  IniFile : TIniFile = nil;
  IniFileName : string = '.\stm32ina2xx.ini';

implementation

uses
  StrUtils, ComPort, HexUtils, Ina219_r_config, Ina226_r_config;

{$R *.dfm}

// ������ ���������� �� .ini
procedure TfrmMain.ReadIni;
begin
// 0.0005024 / 0.0956000
//  Uk := 0.0005004;
//  Ik := 0.09475;
//  cntxyz := 0;
//  flgValueChg := False;
//  flgValueChg := True;
//  MaxSamples := 1000000;

   if IniFile = nil then IniFile := TIniFile.Create(IniFileName);
   if IniFile.ReadString('System','Version','') = '' then begin
     IniFile.WriteString('System','Version', BuildInfoString);
     IniFile.WriteInteger('System','MaxSamples', MaxSamples);
     IniFile.WriteFloat('System','TriggerI', TriggerI);
     IniFile.WriteFloat('System','TriggerU', TriggerU);
     IniFile.WriteInteger('System', 'ChIColor', SetColorI.Color);
     IniFile.WriteInteger('System', 'ChUColor', SetColorU.Color);
     IniFile.WriteBool('System','TriggerUena', CheckBoxTrigerRiseU.Checked);
     IniFile.WriteBool('System','TriggerIena', CheckBoxTrigerRiseI.Checked);

     IniFile.WriteInteger('Setup','Top',Top);
     IniFile.WriteInteger('Setup','Left',Left);
     IniFile.WriteInteger('Setup','Width',Width);
     IniFile.WriteInteger('Setup','Height',Height);
//     IniFile.WriteInteger('Setup','ComPort',iComNum);

     IniFile.WriteFloat('INA219','Iz40mV',I_219_zero_tab[0]);
     IniFile.WriteFloat('INA219','Iz80mV',I_219_zero_tab[1]);
     IniFile.WriteFloat('INA219','Iz160mV',I_219_zero_tab[2]);
     IniFile.WriteFloat('INA219','Iz320mV',I_219_zero_tab[3]);
     IniFile.WriteFloat('INA219','Uz',U_219_zero);
     IniFile.WriteFloat('INA219','Ik',Ik_219);
     IniFile.WriteFloat('INA219','Uk',Uk_219);

     IniFile.WriteFloat('INA226','Iz',I_226_zero);
     IniFile.WriteFloat('INA226','Uz',U_226_zero);
     IniFile.WriteFloat('INA226','Ik',Ik_226);
     IniFile.WriteFloat('INA226','Uk',Uk_226);
   end
   else begin
     MaxSamples := IniFile.ReadInteger('System','MaxSamples', MaxSamples);
     TriggerI := IniFile.ReadFloat('System','TriggerI', TriggerI);
     TriggerU := IniFile.ReadFloat('System','TriggerU', TriggerU);
     CheckBoxTrigerRiseU.Checked := IniFile.ReadBool('System','TriggerUena', CheckBoxTrigerRiseU.Checked);
     CheckBoxTrigerRiseI.Checked := IniFile.ReadBool('System','TriggerIena', CheckBoxTrigerRiseI.Checked);

     Top := IniFile.ReadInteger('Setup','Top',0);
     Left := IniFile.ReadInteger('Setup','Left',0);
     if Screen.DesktopHeight <= Top then Top := 10;
     if Screen.DesktopWidth <= Left then Left := 10;
     Height := IniFile.ReadInteger('Setup','Height',Height);
     Width := IniFile.ReadInteger('Setup','Width',Width);
     sComNane := IniFile.ReadString('Setup','ComPort', sComNane);

     SetColorI.Color := IniFile.ReadInteger('System', 'ChIColor', SetColorI.Color);
     SetColorU.Color := IniFile.ReadInteger('System', 'ChUColor', SetColorU.Color);

     I_219_zero_tab[0]:= IniFile.ReadFloat('INA219','Z_40mV',I_219_zero_tab[0]);
     I_219_zero_tab[1]:= IniFile.ReadFloat('INA219','Z_80mV',I_219_zero_tab[1]);
     I_219_zero_tab[2]:= IniFile.ReadFloat('INA219','Z_160mV',I_219_zero_tab[2]);
     I_219_zero_tab[3]:= IniFile.ReadFloat('INA219','Z_320mV',I_219_zero_tab[3]);
     U_219_zero := IniFile.ReadFloat('INA219','Uz',U_219_zero);
     Ik_219 := IniFile.ReadFloat('INA219','Ik',Ik_219);
     Uk_219 := IniFile.ReadFloat('INA219','Uk',Uk_219);

     I_226_zero := IniFile.ReadFloat('INA226','Iz',I_226_zero);
     U_226_zero := IniFile.ReadFloat('INA226','Uz',I_226_zero);
     Ik_226 := IniFile.ReadFloat('INA226','Ik',Ik_226);
     Uk_226 := IniFile.ReadFloat('INA226','Uk',Uk_226);
   end;
   IniFile.UpdateFile;
end;

// ������ ���������� � *.ini
procedure TfrmMain.WriteIni;
begin
     IniFile.WriteString('System','Version', BuildInfoString);
     IniFile.WriteInteger('System','MaxSamples', MaxSamples);
     IniFile.WriteFloat('System','TriggerI', TriggerI);
     IniFile.WriteFloat('System','TriggerU', TriggerU);
     IniFile.WriteBool('System','TriggerUena', CheckBoxTrigerRiseU.Checked);
     IniFile.WriteBool('System','TriggerIena', CheckBoxTrigerRiseI.Checked);

     IniFile.WriteInteger('Setup','Top',Top);
     IniFile.WriteInteger('Setup','Left',Left);
     IniFile.WriteInteger('Setup','Width',Width);
     IniFile.WriteInteger('Setup','Height',Height);
     IniFile.WriteString('Setup','ComPort',sComNane);

  //  SetColorU.Color := Chart.Series[0].Color;
  //  SetColorI.Color := Chart.Series[1].Color;
    IniFile.WriteInteger('System', 'ChIColor', SetColorI.Color);
    IniFile.WriteInteger('System', 'ChUColor', SetColorU.Color);


     IniFile.WriteFloat('INA219','Iz40mV',I_219_zero_tab[0]);
     IniFile.WriteFloat('INA219','Iz80mV',I_219_zero_tab[1]);
     IniFile.WriteFloat('INA219','Iz160mV',I_219_zero_tab[2]);
     IniFile.WriteFloat('INA219','Iz320mV',I_219_zero_tab[3]);
     IniFile.WriteFloat('INA219','Uz',U_219_zero);
     IniFile.WriteFloat('INA219','Ik',Ik_219);
     IniFile.WriteFloat('INA219','Uk',Uk_219);

     IniFile.WriteFloat('INA226','Iz',I_226_zero);
     IniFile.WriteFloat('INA226','Uz',U_226_zero);
     IniFile.WriteFloat('INA226','Ik',Ik_226);
     IniFile.WriteFloat('INA226','Uk',Uk_226);
     IniFile.UpdateFile;
end;


function Str2dword(const s: string): dword;
var
 i: integer;
 o : string;
 hex : boolean;
begin
    i := 1;
    hex := False;
//    result := 0;
    while (i <= Length(s)) do begin
      if ((s[i] = '0') and (s[i+1] = 'x')) then begin
       hex := True;
       inc(i);
      end
      else if (s[i] = '$') then  hex := True
      else if (((s[i] >= 'a') and (s[i] <= 'f'))
      or ((s[i] >= 'A') and (s[i] <= 'F'))) then begin
       hex := True;
       o := o + s[i];
      end
      else if ((s[i] >= '0') and (s[i] <= '9')) then o := o + s[i];
      inc(i);
    end;
    if hex then result := StrToIntDef('$'+o,0)
    else result := StrToIntDef(o,0)
end;

procedure GetBuildInfo(var V1, V2, V3, V4: word);
var
  VerInfoSize, VerValueSize, Dummy: DWORD;
  VerInfo: Pointer;
  VerValue: PVSFixedFileInfo;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  if VerInfoSize > 0 then
  begin
      GetMem(VerInfo, VerInfoSize);
      try
        if GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo) then
        begin
        
          VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
          with VerValue^ do
          begin
            V1 := dwFileVersionMS shr 16;
            V2 := dwFileVersionMS and $FFFF;
            V3 := dwFileVersionLS shr 16;
            V4 := dwFileVersionLS and $FFFF;
          end;
        end;
      finally
        FreeMem(VerInfo, VerInfoSize);
      end;
  end;
end;

function GetBuildInfoAsString: string;
var
  V1, V2, V3, V4: word;
begin
  GetBuildInfo(V1, V2, V3, V4);
  Result := IntToStr(V1) + '.' + IntToStr(V2) + '.' +
    IntToStr(V3) + '.' + IntToStr(V4);
end;

//������� �� ������ � ����-���������������� ����������� ��������� ����-���������������
//��������� ������� � ������� aStartPos, ����� ������������� aStartPos �� ������
//��������� �� ������������� #0.
function GetNextSubstring(aBuf: string; var aStartPos: integer): string;
var
  vLastPos: integer;
begin
  if (aStartPos < 1) then
    begin
      raise ERangeError.Create('aStartPos ������ ���� ������ 0');
    end;

  if (aStartPos > Length(aBuf) ) then
    begin
      Result := '';
      Exit;
    end;

  vLastPos := PosEx(#0, aBuf, aStartPos);
  Result := Copy(aBuf, aStartPos, vLastPos - aStartPos);
  aStartPos := aStartPos + (vLastPos - aStartPos) + 1;
end;

//��������� ������ aList ��������� � ������� COM �������
procedure GetComPorts(aList: TStrings; aNameStart: string);
var
  vBuf: string;
  vRes: integer;
  vErr: Integer;
  vBufSize: Integer;
  vNameStartPos: Integer;
  vName: string;
begin
  vBufSize := 1024 * 5;
  vRes := 0;

  while vRes = 0 do
    begin
      setlength(vBuf, vBufSize) ;
      SetLastError(ERROR_SUCCESS);
      vRes := QueryDosDevice(nil, @vBuf[1], vBufSize) ;
      vErr := GetLastError();

      //������� ��� ���������
      if (vRes <> 0) and (vErr = ERROR_INSUFFICIENT_BUFFER) then
        begin
          vBufSize := vRes;
          vRes := 0;
        end;

      if (vRes = 0) and (vErr = ERROR_INSUFFICIENT_BUFFER) then
        begin
          vBufSize := vBufSize + 1024;
        end;

      if (vErr <> ERROR_SUCCESS) and (vErr <> ERROR_INSUFFICIENT_BUFFER) then
        begin
          raise Exception.Create(SysErrorMessage(vErr) );
        end
    end;
  setlength(vBuf, vRes) ;

  vNameStartPos := 1;
  vName := GetNextSubstring(vBuf, vNameStartPos);

  aList.BeginUpdate();
  try
    aList.Clear();
    while vName <> '' do
      begin
        if AnsiStartsStr(aNameStart, vName) then
          aList.Add(vName);
        vName := GetNextSubstring(vBuf, vNameStartPos);
      end;
  finally
    aList.EndUpdate();
  end;
end;


procedure TfrmMain.btnReScanComDevices(Sender: TObject);
begin
  ReScanComDevices;
end;

function TfrmMain.IndexOfComName(const S: String): Integer;
var
  I : Integer;
begin
  Result := -1;
  for I := 0 to ComboBox.Items.Count-1 do
  begin
    if ComboBox.Items.Strings[I] = S then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

function TfrmMain.SetComName: boolean;
begin
  result:=False;
  sComNane:=ComboBox.Items.Strings[ComboBox.ItemIndex];
  if(sComNane='') then begin
    StatusBar.Panels[0].Text:='COM?';
    StatusBar.Panels[2].Text:='�� ������ COM ����!';
  end
  else begin
    StatusBar.Panels[0].Text:=sComNane;
    StatusBar.Panels[2].Text:='������ '+sComNane+'.';
    result:=True;
  end;
end;

procedure TfrmMain.ReScanComDevices;
begin
  ComboBox.Items.Clear;
  GetComPorts(ComboBox.Items, 'COM');
  if(sComNane <> '') then begin
    ComboBox.ItemIndex := IndexOfComName(sComNane);
  end
  else
    ComboBox.ItemIndex:=0;
  SetComName;
end;

procedure TfrmMain.GetUIkParms;
begin
    DecimalSeparator := '.';
    Ik := StrToFloat(EditIk.Text);
    Uk := StrToFloat(EditUk.Text);
end;

procedure TfrmMain.ShowUIkParms;
begin
    DecimalSeparator := '.';
    EditIk.Text:=FormatFloat('0.00000000', Ik);
    EditUk.Text:=FormatFloat('0.00000000', Uk);
end;

procedure TfrmMain.GetScrParms;
begin
    DecimalSeparator := '.';
    MaxSamples := Str2dword(EditSizeGrf.Text);
    TriggerI := StrToFloat(EditTriggerI.Text);
    TriggerU := StrToFloat(EditTriggerU.Text);
end;

procedure TfrmMain.ShowScrParms;
begin
    DecimalSeparator := '.';
    EditSizeGrf.Text := IntToStr(MaxSamples);
    EditTriggerI.Text:=FormatFloat('0.0000', TriggerI);
    EditTriggerU.Text:=FormatFloat('0.0000', TriggerU);
end;

procedure TfrmMain.ShowLabelsMX;
begin
        if ((ChartEnables and 2) <> 0)  and (SamplesCount <> 0) then begin
            OldsI := SumI/SamplesCount;
            LabelMXI.Caption := 'I:' + FormatFloat('# ##0.000000', OldsI);
        end
        else
            LabelMXI.Caption := 'I#' + FormatFloat('# ##0.000000', OldCurI);
        if ((ChartEnables and 1) <> 0) and (SamplesCount <> 0) then begin
            OldsU := SumU/SamplesCount;
            LabelMXU.Caption := 'U:' + FormatFloat('# ##0.000000', SumU/SamplesCount);
        end
        else
            LabelMXU.Caption := 'U#' + FormatFloat('# ##0.000000', OldCurU);
end;

procedure TfrmMain.ShowSmps;
var
k : double;
begin
  if blk_cfg.time_us <> 0 then begin
    if ChartEnables = CHART_UI_MASK then begin
      k := 2000000.0/blk_cfg.time_us;
    end
    else begin
      k := 1000000.0/blk_cfg.time_us;
    end;
    StatusBar.Panels[1].Text := FormatFloat('# ##0.0', k) + ' sps';
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  DecimalSeparator := '.';
  flgValueChg := False;

  DeviceTypeRecognized := False;

  BuildInfoString := GetBuildInfoAsString;
  Caption := Application.Title + ' ver ' + BuildInfoString;
  SetGrfMarging;

  SamplesAutoStop := False;

  Ini_Cfg.none := $00;
  dev_id := 0;
  dev_send_err := 0;
  ChartEnables := 0;
  blk_cfg.clk_khz := SMBus_Speed_kHz;

  GetScrParms;

  SetColorU.Color := Chart.Series[CHART_U_NUM].Color;
  SetColorI.Color := Chart.Series[CHART_I_NUM].Color;

  ReadIni;

  Chart.Series[CHART_U_NUM].Color := SetColorU.Color;
  Chart.Series[CHART_I_NUM].Color := SetColorI.Color;

  ReScanComDevices;

  ShowScrParms;
  flgValueChg := True;
end;

procedure TfrmMain.ChComName(Sender: TObject);
begin
  SetComName;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  GetScrParms;
  WriteIni;
end;

procedure TfrmMain.ButtonOpenClick(Sender: TObject);
begin
   Timer1.Enabled := False;
   SamplesEna := False;
   if not flgComOpen then begin
    if SetComName then begin
      if OpenCom(sComNane) then begin
        PurgeCom(PURGE_TXCLEAR or PURGE_RXCLEAR);
        ClearGrf;
        ChartEnables := 0;
        if not GetDevVersion then begin
          CloseCom;
          if dev_id <> STM32_DEVICE_ID then begin
            ShowMessage('Error device ID!'+#13#10+'Com closed.');
            StatusBar.Panels[2].Text:='�� ��� ID � ���������� �� '+ sComNane+'!';
          end else begin
            ShowMessage('Error read device config!'+#13#10+'Com closed.');
            StatusBar.Panels[2].Text:='������ � ����� ������������ ���������� �� '+ sComNane+'!';
          end;
        end
        else begin
          ComboBox.Enabled := False;
          btnQueryDosDevice.Enabled := False;
          ButtonOpen.Caption := 'Close';
          ButtonStop.Enabled := True;
          PurgeCom(PURGE_TXCLEAR or PURGE_RXCLEAR);
          if RdAllRegs then begin
            ShowAllRegs;
            ButtonRdAllRegs.Enabled := True;
            ButtonConfigReg.Enabled := True;
            ButtonStart.Enabled := True;
            ButtonStore.Enabled := True;
//            StatusBar.Panels[2].Text:=sComNane+' ������.';
            PurgeCom(PURGE_TXCLEAR or PURGE_RXCLEAR);
            ClearGrf;
            ConnectStartTime := GetTime;
            if dev_ina226 then begin
//              if GetSmbusAlert then
//                Caption := Application.Title + ' ver ' + BuildInfoString + ' (INA226:' + IntToHex(dev_alert_addr,2) + ')'
//              else
                Caption := Application.Title + ' ver ' + BuildInfoString + ' (INA226)';
              Form226Config.GetParams;
            end
            else begin
              Caption := Application.Title + ' ver ' + BuildInfoString + ' (INA219)';
              Form219Config.GetParams;
            end;
            ShowUIkParms;
            DeviceTypeRecognized := True;
//            SamplesEna := True;
//            Timer1.Enabled := True;
          end else begin
            StatusBar.Panels[2].Text:='������ ��� ����� ��������� INA2XX � ���������� �� '+ sComNane+'!';
            ShowMessage(StatusBar.Panels[2].Text);
          end;
        end;
      end
      else begin
        StatusBar.Panels[2].Text:='������ �������� '+ sComNane+'!';
        ShowMessage(StatusBar.Panels[2].Text);
      end;
    end
    else begin
      StatusBar.Panels[2].Text:='�������� COM ����!';
    end;
  end
  else begin
     CloseCom;
     ButtonOpen.Caption := 'Open';
     ComboBox.Enabled := True;
     btnQueryDosDevice.Enabled := True;

     ButtonStart.Enabled := False;
     ButtonStop.Enabled := False;
     ButtonConfigReg.Enabled := False;
     ButtonStore.Enabled := False;
     ButtonRdAllRegs.Enabled := False;
     StatusBar.Panels[2].Text:=sComNane+' ������.';
  end;
end;

function TfrmMain.SetDevIniCfg(mode : integer) : boolean;
begin
   result := False;
   Timer1.Enabled := False;
   if dev_ina226 then begin
     ChartEnables := Form226Config.DevIniCfg(mode);
   end
   else begin
     ChartEnables := Form219Config.DevIniCfg(mode);
   end;
   buftx[2] := CMD_SET_INI;
   buftx[3] := SizeOf(blk_cfg);
   move(blk_cfg, buftx[4], SizeOf(blk_cfg));
   if SendBlk then begin
//     sleep(20);
     if ReadBlk(buftx[2]) and (lenrx = SizeOf(blk_cfg)) then begin
       move(bufrx, blk_cfg, SizeOf(blk_cfg));
       StatusBar.Panels[2].Text:='������������ �������� � ���������� �� '+ sComNane+'.';
       result := True;
     end
     else begin
       StatusBar.Panels[2].Text:='������ ������ ������������ � ���������� �� '+ sComNane+'!';
     end;
   end;
   if SamplesEna then Timer1.Enabled := True;
end;

function TfrmMain.GetSmbusAlert : boolean;
begin
     result := False;
     Timer1.Enabled := False;
     buftx[2]:=CMD_GET_DAA; // Get SMBUS dev Alert addr
     buftx[3]:=0;
     if SendBlk then begin
//       sleep(20);
       if ReadBlk(buftx[2]) and (lenrx = 1) then begin
         dev_alert_addr := bufrx[0];
         result := True;
       end;
     end;
     if SamplesEna then Timer1.Enabled := True;
end;

function TfrmMain.GetDevIniCfg : boolean;
begin
     result := False;
     Timer1.Enabled := False;
     buftx[2]:=CMD_SET_INI; // Set/Get CFG/ini & Start measure
     buftx[3]:=0;
     if SendBlk then begin
//       sleep(20);
       if ReadBlk(buftx[2]) and (lenrx = SizeOf(blk_cfg)) then begin
         move(bufrx, blk_cfg, SizeOf(blk_cfg));
         result := True;
       end;
     end;
     if SamplesEna then Timer1.Enabled := True;
end;


procedure TfrmMain.ButtonStartClick(Sender: TObject);
begin
    if SetDevIniCfg(1) then begin
        ConnectStartTime := GetTime;
        StatusBar.Panels[2].Text:='�������� ����������� ������ INA2XX � ���������� �� '+ sComNane+'.';
        SetParStart;
        if SamplesAutoStop then begin
           SamplesAutoStop := False;
           ClearGrf;
        end;
        SamplesEna := True;
        Timer1.Enabled := True;
   end;
end;

procedure TfrmMain.ButtonStopClick(Sender: TObject);
begin
   if (not ReadStatus)
    or (not StopReadDevice) then
      StatusBar.Panels[2].Text:='������ �������� � ���������� �� '+ sComNane+'!'
   else begin
      StatusBar.Panels[2].Text:='����������� ������ ���������� �� '+ sComNane+' �����������. ������� ' + IntToStr(dev_not_send_count) + ' ������, �������: ' + IntToStr(dev_all_send_count) + '.';
      SamplesEna := False;
      Timer1.Enabled := False;
      PurgeCom(PURGE_TXCLEAR or PURGE_RXCLEAR);
      while ReadGgfData do ;
      PurgeCom(PURGE_TXCLEAR or PURGE_RXCLEAR);
      SetParStart;
   end;
end;

procedure TfrmMain.ButtonConfigRegClick(Sender: TObject);
begin
  if RdAllRegs then begin
  if dev_ina226 then begin
    Form226Config.Left := Left + (Width div 2) - Form226Config.Width div 2;
    Form226Config.Top := Top + (Height div 2) - Form226Config.Height div 2;
    FormConfigOk := Form226Config.ShowModal
  end
  else  begin
    Form219Config.Left := Left + (Width div 2) - Form219Config.Width div 2;
    Form219Config.Top := Top + (Height div 2) - Form219Config.Height div 2;
    FormConfigOk := Form219Config.ShowModal;
  end;
  if FormConfigOk = mrOk then begin
    Timer1.Enabled := False;

    buftx[2]:=CMD_SET_REG; // Set Reg
    buftx[3]:=4;
    buftx[4]:=INA2XX_I2C_ADDR;
    buftx[5]:=0;
    buftx[6]:= ina2xx_reg.config;
    buftx[7]:= ina2xx_reg.config  shr 8;

    if SendBlk then begin
//    sleep(15);
      if not ReadBlk(buftx[2]) or (lenrx <> 4) then begin
        ShowMessage('Send config reg error!');
        FormConfigOk := mrIgnore;
      end
      else begin
          StatusBar.Panels[2].Text:='�������� ������������ �������� � ����������.';
      end;
    end else begin
      ShowMessage('Send config reg error!');
      FormConfigOk := mrIgnore;
    end;
    ShowSmps;
    if SamplesEna then Timer1.Enabled := True;
  end;
  end;
end;

procedure TfrmMain.ButtonStoreClick(Sender: TObject);
begin
    ButtonStopClick(Sender);
    ButtonConfigRegClick(Sender);
    if FormConfigOk = mrOk then begin
      Timer1.Enabled := False;
      if SetDevIniCfg(0) then begin
        buftx[2]:=CMD_WRF_INI; // Store CFG/ini in Flash
        buftx[3]:=0;
        if SendBlk then begin
//        sleep(15);
          if ReadBlk(buftx[2]) and (lenrx = 0) then begin
            StatusBar.Panels[2].Text:='������������ �������� �� Flash � ���������� �� '+ sComNane+'.';
          end;
        end;
     end;
     if SamplesEna then Timer1.Enabled := True;
   end;
end;

function TfrmMain.StopReadDevice: boolean;
var
 i : integer;
begin
  result := False;
  for i:=0 to 5 do begin
    PurgeCom(PURGE_TXCLEAR or PURGE_RXCLEAR);
    buftx[2]:=CMD_SET_INI; // Set/Get CFG/ini & Start measure
    buftx[3]:=6;
    buftx[4]:=0; // read regs = 0
    buftx[5]:=0; // write regs = 0
    buftx[6]:=$90; // 400
    buftx[7]:=$01; //
    buftx[8]:=$90; // 400
    buftx[9]:=$01; //
    if SendBlk then begin
//      sleep(5);
      if ReadBlk(buftx[2]) and (lenrx = SizeOf(blk_cfg)) then begin
        move(bufrx, blk_cfg, SizeOf(blk_cfg));
        sleep(20);
        PurgeCom(PURGE_TXCLEAR or PURGE_RXCLEAR);
        result := True;
        break;
      end;
    end;
  end;
end;

function TfrmMain.GetDevVersion: boolean;
var
 i : integer;
begin
  result := False;
  for i:=0 to 5 do begin
    PurgeCom(PURGE_TXCLEAR or PURGE_RXCLEAR);
    buftx[2]:= CMD_GET_VER; // Get Version
    buftx[3]:=0;
    if SendBlk then begin
      sleep(5);
      if ReadBlk(buftx[2]) and (lenrx = 4) then begin
        dev_id := bufrx[2];
        dev_ver := bufrx[0] or (bufrx[1] shl 8);
        StatusBar.Panels[2].Text:='���������� ID:' + IntToHex(dev_id, 2) +' ������ '+IntToStr((bufrx[1] and $F0) shr 4)+'.'+IntToStr(bufrx[1] and $F)+'.'+IntToStr((bufrx[0] and $F0) shr 4)+'.'+IntToStr(bufrx[0] and $0f)+' ���������� �� '+ sComNane +'.';
        if dev_id = STM32_DEVICE_ID then begin
          if StopReadDevice
            and ReadRegister(INA226_MID_REG)
            and ReadRegister(INA226_DID_REG) then begin
              if (ina2xx_reg.mid = INA226_MID)
              and (ina2xx_reg.did = INA226_DID) then
                dev_ina226 := True
              else
                dev_ina226 := False;
            result := True;
          end;
          exit;
        end;
      end;
    end;
  end;
end;

function TfrmMain.ResetIna2xx : boolean;
begin
   Timer1.Enabled := False;
   result := true;
   buftx[2]:=CMD_SET_REG; // Cmd: Set word
   buftx[3]:=4;
   buftx[4]:=INA2XX_I2C_ADDR;
   buftx[5] := 0;
   buftx[6] := $80;
   buftx[7] := 0;
   if SendBlk and ReadBlk(buftx[2]) and (lenrx = 4) then begin
//     sleep(20);
     if not RdAllRegs then begin
       result := false;
     end;
   end else begin
     result := false
   end;
   if SamplesEna then Timer1.Enabled := True;
end;

function TfrmMain.ReadRegister(regnum : integer) : boolean;
var
 i: integer;
 ft : boolean;
begin
   ft := Timer1.Enabled;
   Timer1.Enabled := False;
   if regnum = INA226_MID_REG then
        i := 8
   else if regnum = INA226_DID_REG then
        i := 9
   else
     i := regnum and 7;
   result := true;
   buftx[2]:=CMD_GET_REG; // Cmd: Get word
   buftx[3]:=2;
   buftx[4]:=INA2XX_I2C_ADDR;
   buftx[5]:= regnum;
   if SendBlk then begin
//     sleep(15);
     if ReadBlk(buftx[2]) and (lenrx = 4) then begin
        ina2xx_reg.w[i] := bufrx[3] or (bufrx[2] shl 8);
     end else begin
      result := false;
     end;
   end else begin
      result := false;
   end;
   Timer1.Enabled := ft;
end;

function TfrmMain.ReadStatus : boolean;
var
 ft : boolean;
begin
   ft := Timer1.Enabled;
   Timer1.Enabled := False;
   result := true;
   buftx[2]:=CMD_GET_STA; // Cmd: Get Status
   buftx[3]:=0;
   if SendBlk then begin
//     sleep(15);
     if ReadBlk(buftx[2]) and (lenrx = 8) then begin
        dev_all_send_count :=  bufrx[0] or (bufrx[1] shl 8) or (bufrx[2] shl 16) or (bufrx[3] shl 24);
        dev_not_send_count :=  bufrx[4] or (bufrx[5] shl 8) or (bufrx[6] shl 16) or (bufrx[7] shl 24);
     end
     else begin
      StatusBar.Panels[2].Text:='������ ��� ����� ������� ���������� �� '+ sComNane+'!';
      result := false;
     end;
   end
   else begin
      StatusBar.Panels[2].Text:='������ ��� ����� ������� ���������� �� '+ sComNane+'!';
      result := false;
   end;
   Timer1.Enabled := ft;
end;

function TfrmMain.RdAllRegs : boolean;
var
 i: integer;
 ft : boolean;
begin
   ft := Timer1.Enabled;
   Timer1.Enabled := False;
   result := true;
   buftx[2]:=CMD_GET_REG; // Cmd: Get word
   buftx[3]:=2;
   buftx[4]:=INA2XX_I2C_ADDR;
   for i:=0 to 7 do begin
     buftx[5] := i;
     if SendBlk and ReadBlk(buftx[2]) and (lenrx = 4) then begin
       ina2xx_reg.w[i] := bufrx[2] or (bufrx[3] shl 8);
     end
     else begin
      StatusBar.Panels[2].Text:='������ ��� ����� ��������� INA2XX � ���������� �� '+ sComNane+'!';
      result := false;
      break;
     end;
   end;
//   if result then begin
//     I_zero := I_219_zero_tab[(ina2xx_reg.config and ControlGainMsk) shr ControlGainShl];
//   end;
   Timer1.Enabled := ft;
end;

procedure TfrmMain.ShowAllRegs;
begin
   EditRegs.Text :=
     IntToHex(ina2xx_reg.w[0],4) + ', '
   + IntToHex(ina2xx_reg.w[1],4) + ', '
   + IntToHex(ina2xx_reg.w[2],4) + ', '
   + IntToHex(ina2xx_reg.w[3],4) + ', '
   + IntToHex(ina2xx_reg.w[4],4) + ', '
   + IntToHex(ina2xx_reg.w[5],4) + ', '
   + IntToHex(ina2xx_reg.w[6],4) + ', '
   + IntToHex(ina2xx_reg.w[7],4);
//   StatusBar.Panels[2].Text:='REGS: ' + EditRegs.Text;
end;


procedure TfrmMain.ButtonRdAllRegsClick(Sender: TObject);
begin
   if RdAllRegs then begin
     ShowAllRegs;
     StatusBar.Panels[2].Text:='REGS: ' + EditRegs.Text;
   end;
end;

procedure TfrmMain.AddCrfSamples(count : integer);
var
i : integer;
k, idx : double;
flg : boolean;
begin
  if ChartEnables = CHART_UI_MASK then begin
    k := blk_cfg.time_us/500.0;
  end
  else begin
    k := blk_cfg.time_us/1000.0;
  end;
  idx := SamplesCount*k;
  if idx >= MaxSamples then begin
    SamplesAutoStop := True;
    ShowLabelsMX;
    exit;
  end;
  i := 0;
  while(i < count) do begin
    if (ChartEnables and CHART_I_MASK) <> 0 then begin
      OldCurI := CurI;
      CurI := bufsmp[i]*Ik + I_zero;
      Inc(i);
    end;
    if (ChartEnables and CHART_U_MASK) <> 0 then begin
      OldCurU := CurU;
      CurU := bufsmp[i]*Uk + U_zero;
      Inc(i);
    end;
    flg := True;
    if SamplesCount = 0 then begin
      if ((ChartEnables and CHART_I_MASK) <> 0) then begin
        if TriggerIEnable then begin
          // ���� �������� I
          if (CurI < TriggerI) then begin
            TriggerILow := True;
            flg := False;
          end
          else begin
            if not TriggerILow then
              flg := False;
          end;
        end;
      end;
      if ((ChartEnables and CHART_U_MASK) <> 0) then begin
        if TriggerUEnable then begin
          // ���� �������� U
          if (CurU < TriggerU) then begin
            TriggerULow := True;
            flg := False;
          end
          else begin
            if not TriggerULow then
              flg := False;
          end;
        end;
      end;
      if flg then begin
        if (TriggerIEnable or TriggerUEnable) then begin // ������� ?
          // �������� ����. �����
          if (ChartEnables and CHART_I_MASK) <> 0 then begin
            Chart.Series[CHART_I_NUM].Clear;
            Chart.Series[CHART_I_NUM].AddXY(idx, OldCurI,'',0);
            SumI := SumI + CurI;
          end;
          if (ChartEnables and CHART_U_MASK) <> 0 then begin
            Chart.Series[CHART_U_NUM].Clear;
            if (ChartEnables = CHART_UI_MASK) then
                Chart.Series[CHART_U_NUM].AddXY(idx+k/2, OldCurU,'',0)
            else
                Chart.Series[CHART_U_NUM].AddXY(idx, OldCurU,'',0);
            SumU := SumU + CurU;
          end;
          Inc(SamplesCount);
          idx := SamplesCount*k; //  idx := idx + k;
        end;
      end;
    end; // if SamplesCount = 0
    if (ChartEnables = CHART_UI_MASK) then begin
      Chart.Series[CHART_I_NUM].AddXY(idx, CurI,'',0);
      Chart.Series[CHART_U_NUM].AddXY(idx+k/2, CurU,'',0);
      if flg then begin
        SumU := SumU + CurU;
        SumI := SumI + CurI;
      end;
    end
    else if (ChartEnables and CHART_I_MASK) <> 0 then begin
      Chart.Series[CHART_I_NUM].AddXY(idx, CurI,'',0);
      if flg then begin
        SumI := SumI + CurI;
      end;
    end
    else if (ChartEnables and CHART_U_MASK) <> 0 then begin
      Chart.Series[CHART_U_NUM].AddXY(idx, CurU,'',0);
      if flg then begin
        SumU := SumU + CurU;
      end;
    end;
    if flg then begin
      Inc(SamplesCount);
      idx := SamplesCount*k; // idx := idx + k;
      if idx >= MaxSamples then begin
        ShowSmps;
        ShowLabelsMX;
        if (not ReadStatus)
        or (not StopReadDevice) then
          StatusBar.Panels[2].Text:='������ �������� � ���������� �� '+ sComNane+'!'
        else begin
          StatusBar.Panels[2].Text:='����������� ������ ����������� �� ����� ������. ������� ' + IntToStr(dev_not_send_count) + ' ������, �������: ' + IntToStr(dev_all_send_count) + '.';
          SamplesEna := False;
          Timer1.Enabled := False;
          PurgeCom(PURGE_TXCLEAR or PURGE_RXCLEAR);
          while ReadGgfData do ;
            PurgeCom(PURGE_TXCLEAR or PURGE_RXCLEAR);
        end;
        SamplesAutoStop := True;
        break;
      end; // if idx >= MaxSamples
    end; // if flg
  end; // while(i < count)
end;


function TfrmMain.SendBlk : boolean;
begin
   result := FALSE;
   buftx[0]:=$55;
   buftx[1]:=$55;
   if not WriteCom(@buftx,buftx[3]+4) then begin
    StatusBar.Panels[2].Text:='������ ������ � '+ sComNane+'!';
    exit;
   end;
   sleep(20);
   result := TRUE;
end;

function TfrmMain.ReadGgfData : boolean;
var
buf : array [0..3] of byte;
begin
    result := False;
    while ReadCom(@buf,4) do begin // ������ ���������
      if(buf[0] = $55)
      and (buf[1] = $55)
//      and (buf[3] > 0)
      and (buf[3] <= 60) then begin
        // ���-�� ����
        if ((buf[2] and $7f) = RES_OUT_REGS) then begin
          // ���� ������ ��� ��������
          if ((buf[2] and $80) = 0) then begin
            if (buf[3] <> 0) then begin
              if ReadCom(@bufsmp, buf[3]) then begin
                if SamplesEna then AddCrfSamples(buf[3] div 2);
              end else begin
                if wait_cnt = 0 then PurgeCom(PURGE_TXCLEAR or PURGE_RXCLEAR);
              end;
            end;
          end
          else begin
            // ������ ��� ������ ��������� �� �������
            if (buf[3] <> 0) then begin
              if ReadCom(@bufrx, buf[3]) then begin
                dev_all_send_count :=  bufrx[0] or (bufrx[1] shl 8) or (bufrx[2] shl 16) or (bufrx[3] shl 24);
                dev_not_send_count :=  bufrx[4] or (bufrx[5] shl 8) or (bufrx[6] shl 16) or (bufrx[7] shl 24);
                dev_send_err := bufrx[8];
              end
              else begin
                if wait_cnt = 0 then PurgeCom(PURGE_TXCLEAR or PURGE_RXCLEAR);
                dev_all_send_count := 0;
                dev_not_send_count := 0;
                dev_send_err := 255;
              end;
            end
            else begin
                if wait_cnt = 0 then PurgeCom(PURGE_TXCLEAR or PURGE_RXCLEAR);
                dev_all_send_count := 0;
                dev_not_send_count := 0;
                dev_send_err := 254;
             end;
          end;
        end else begin
          // �� $07
          if (buf[3] <> 0) then begin
            if not ReadCom(@bufrx, buf[3]) then begin
              // �� ����������� - ���� �� ������?
              PurgeCom(PURGE_TXCLEAR or PURGE_RXCLEAR);
            end
          end;
          if (wait_cnt > 0) then begin
            //  �������� ������ �������
            if ((buf[2] and $7f) = wait_id) then begin
              // ����� ������
              wait_cnt := 0;
              lenrx := buf[3];
              if ((buf[2] and $80) = 0) then
                 result := True
              else
                 result := False;
              exit;
            end else begin
              Inc(wait_cnt);
              if wait_cnt < 33 then continue
              else begin
                // ����� �� ������
                wait_cnt := 0;
                lenrx := 0;
                StatusBar.Panels[2].Text:='��� ������ �� ���������� � '+ sComNane+'!';
                exit;
              end;
            end;
          end;
        end;
      end;
    end;
    wait_cnt := 0;
end;

function TfrmMain.ReadBlk(id : byte) : boolean;
begin
   wait_cnt := 1;
   wait_id := id;
   result := ReadGgfData;
end;

procedure TfrmMain.TimerTimer(Sender: TObject);
var
 t : TDateTime;
begin
    ReadGgfData;
    if SamplesEna then begin
      if dev_send_err <> 0 then begin
        if not StopReadDevice then
          StatusBar.Panels[2].Text:='������ �������� ������� �������� � ���������� �� '+ sComNane+'!'
        else begin
          StatusBar.Panels[2].Text:='���� ��������� ������, ������ N' + IntToStr(dev_send_err)
          +': ������� ' + IntToStr(dev_not_send_count) + ' ������, �������: ' + IntToStr(dev_all_send_count) + '!';
          SamplesEna := False;
          Timer1.Enabled := False;
          PurgeCom(PURGE_TXCLEAR or PURGE_RXCLEAR);
        end;
        dev_send_err := 0;
        SamplesAutoStop := True;
      end;
      t := GetTime;
      if (t - ConnectStartTime) > 2/864000.0 then begin
        ConnectTime := ConnectTime + t - ConnectStartTime;
        ConnectStartTime := t;
//        StatusBar.Panels[1].Text := FormatFloat('# ##0.', (SamplesCount/86400.0)/ConnectTime ) + ' sps';
        ShowSmps;
        ShowLabelsMX;
      end;
    end;
end;


procedure TfrmMain.ClearGrf;
var
i : integer;
begin
    for i:=0 to Chart.SeriesCount-1 do Chart.Series[i].Clear;
    ConnectTime := 0;
    ConnectStartTime := GetTime;
    SamplesCount := 0;
    SumI := 0.0;
    SumU := 0.0;
end;

procedure TfrmMain.ButtonClrGrfClick(Sender: TObject);
begin
    if flgComOpen then begin
      PurgeCom(PURGE_TXCLEAR or PURGE_RXCLEAR);
      ClearGrf;
      SetParStart;
      ConnectStartTime := GetTime;
    end
    else
      ClearGrf;

end;


procedure TfrmMain.ButtonPrtGrfClick(Sender: TObject);
begin
    ChartPreviewer.Execute;
end;

procedure TfrmMain.ButtonSaveGRFClick(Sender: TObject);
var
i, data_cont : integer;
bfile : THandle;
s: string;
x,y : double;
begin
    case ChartEnables of
     CHART_I_MASK : data_cont := Chart.Series[CHART_I_NUM].Count;
     CHART_U_MASK : data_cont := Chart.Series[CHART_U_NUM].Count;
     CHART_UI_MASK : data_cont := Chart.Series[CHART_U_NUM].Count;
    else data_cont := 0;
    end;
    if (data_cont <> 0) then begin
     with SaveDialog do begin
      FilterIndex:=0;
      FileName := 'data.csv';
      InitialDir := '.';
      DefaultExt := 'csv';
      Filter := 'csv files (*.csv)|*.csv';
      Options:=Options+[ofFileMustExist]-[ofHideReadOnly]
        +[ofNoChangeDir]-[ofNoLongNames]-[ofNoNetworkButton]-[ofHideReadOnly]
        -[ofOldStyleDialog]-[ofOverwritePrompt]+[ofPathMustExist]
        -[ofReadOnly]-[ofShareAware]-[ofShowHelp];
      Title:='��������� ������ � ����';
     end;//with
     if SaveDialog.Execute then begin
      Repaint;
      bfile := FileCreate(SaveDialog.FileName);
      if bfile<>INVALID_HANDLE_VALUE then begin
        s:='X;Y;SPS~'+FormatFloat('0.0',(SamplesCount/86400.0)/ConnectTime)+#13+#10;
        FileWrite(bfile, s[1], Length(s));
        for i:=0 to data_cont -1  do begin
          if (ChartEnables and 1) <> 0 then begin
            try
             x := Chart.Series[CHART_U_NUM].YValue[i];
            except
             x := 0;
            end;
          end else x := 0;
          if (ChartEnables and 2) <> 0 then begin
            try
             y:=Chart.Series[CHART_I_NUM].YValue[i];
            except
             y := -4096;
            end;
          end else y := 0;
          s:=FloatToStr(x)+';'
           +FloatToStr(y)+#13+#10;
          FileWrite(bfile, s[1],Length(s));
        end;
      end;
      FileClose(bfile);
     end;
    end;
end;

function TfrmMain.GrfSetColor(ChNum : integer): integer;
begin
  ColorDialog.Color := Chart.Series[ChNum].SeriesColor; //xShape[ChNum].Brush.Color;
  if ColorDialog.Execute then
   Chart.Series[ChNum].SeriesColor:=ColorDialog.Color;
  result := ColorDialog.Color
end;


procedure TfrmMain.ButtonAsizeClick(Sender: TObject);
begin
   if(Chart.LeftAxis.Automatic) then begin
    ButtonASize.Caption:='Auto';
    Chart.LeftAxis.Automatic:=False;
    Chart.RightAxis.Automatic:=False;
    ButtonScalM.Visible:=True;
    ButtonScalP.Visible:=True;
  end
  else begin
    ButtonASize.Caption:='Manual';
    Chart.LeftAxis.Automatic:=True;
    Chart.RightAxis.Automatic:=True;
    ButtonScalM.Visible:=False;
    ButtonScalP.Visible:=False;
  end;
end;

procedure TfrmMain.ButtonScalMClick(Sender: TObject);
var
d : double;
begin
  if(not Chart.LeftAxis.Automatic) then begin
    d:= (Chart.LeftAxis.Maximum - Chart.LeftAxis.Minimum)/25;
    Chart.LeftAxis.Minimum:=Chart.LeftAxis.Minimum - d;
    Chart.LeftAxis.Maximum:=Chart.LeftAxis.Maximum + d;
    d:= (Chart.RightAxis.Maximum - Chart.RightAxis.Minimum)/25;
    Chart.RightAxis.Minimum:=Chart.RightAxis.Minimum - d;
    Chart.RightAxis.Maximum:=Chart.RightAxis.Maximum + d;
  end;
end;


procedure TfrmMain.ButtonScalPClick(Sender: TObject);
var
d : double;
begin
  if(not Chart.LeftAxis.Automatic) then begin
    d:= (Chart.LeftAxis.Maximum - Chart.LeftAxis.Minimum)/25;
    Chart.LeftAxis.Minimum:=Chart.LeftAxis.Minimum + d;
    Chart.LeftAxis.Maximum:=Chart.LeftAxis.Maximum - d;
    d:= (Chart.RightAxis.Maximum - Chart.RightAxis.Minimum)/25;
    Chart.RightAxis.Minimum:=Chart.RightAxis.Minimum + d;
    Chart.RightAxis.Maximum:=Chart.RightAxis.Maximum - d;
  end;
end;


procedure TfrmMain.SetGrfMarging;
begin
  if CheckBoxOpenGL.Checked then begin
    Chart.MarginBottom := 5;
    Chart.MarginTop := 2;
    Chart.MarginRight := 2;
    Chart.MarginLeft := 2;
  end else begin
    Chart.MarginBottom := 2;
    Chart.MarginLeft := 2;
    Chart.MarginRight := 2;
    Chart.MarginTop := 2;
  end;
end;

procedure TfrmMain.CheckBoxOpenGLClick(Sender: TObject);
begin
  TeeOpenGL1.Active := CheckBoxOpenGL.Checked;
  SetGrfMarging;
end;


procedure TfrmMain.CheckBoxTrigerClick(Sender: TObject);
begin
  if flgValueChg then
    SetParStart;
end;

procedure TfrmMain.SetParStart;
begin
        GetScrParms;
        ShowScrParms;

        TriggerIEnable := CheckBoxTrigerRiseI.Checked;
        TriggerUEnable := CheckBoxTrigerRiseU.Checked;
        TriggerILow := False;
        TriggerULow := False;

        if not DeviceTypeRecognized then exit;

        GetUIkParms;
        ShowUIkParms;

        if dev_ina226 then begin
          Form226Config.GetParamIz;
          Form226Config.SetParamIU(Ik, Uk);
        end
        else begin
          Form219Config.GetParamIz;
          Form219Config.SetParamIU(Ik, Uk);
        end;
end;

procedure TfrmMain.SetColorIMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then // mbLeft
   SetColorI.Color := GrfSetColor(CHART_I_NUM)
  else
    if Chart.Series[CHART_I_NUM].Visible then
      Chart.Series[CHART_I_NUM].Visible := False
    else
      Chart.Series[CHART_I_NUM].Visible := True;

end;

procedure TfrmMain.SetColorUMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then // mbLeft
    SetColorU.Color := GrfSetColor(CHART_U_NUM)
  else
   if Chart.Series[CHART_U_NUM].Visible then
    Chart.Series[CHART_U_NUM].Visible := False
   else
    Chart.Series[CHART_U_NUM].Visible := True;
end;

end.

