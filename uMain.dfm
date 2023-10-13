object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Pesquisa de conte'#250'do via API-GitHub'
  ClientHeight = 703
  ClientWidth = 1031
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Padding.Left = 10
  Padding.Top = 10
  Padding.Right = 10
  Padding.Bottom = 10
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 10
    Top = 10
    Width = 1011
    Height = 99
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 179
      Top = 22
      Width = 69
      Height = 13
      Caption = 'Pesquisar por:'
    end
    object rdOpcoes: TRadioGroup
      Left = 1
      Top = 1
      Width = 108
      Height = 97
      Align = alLeft
      Caption = 'Op'#231#245'es:'
      Items.Strings = (
        'Usu'#225'rio'
        'Reposit'#243'rio'
        'Organiza'#231#227'o')
      TabOrder = 0
      OnClick = rdOpcoesClick
    end
    object edtPesquisa: TEdit
      Left = 254
      Top = 19
      Width = 256
      Height = 21
      TabOrder = 1
    end
    object Panel1: TPanel
      Left = 140
      Top = 46
      Width = 462
      Height = 41
      Padding.Left = 60
      Padding.Right = 30
      TabOrder = 2
      object btnget: TBitBtn
        Tag = 1
        AlignWithMargins = True
        Left = 64
        Top = 4
        Width = 74
        Height = 33
        Align = alLeft
        Cancel = True
        Caption = 'Get'
        NumGlyphs = 2
        TabOrder = 0
        OnClick = btngetClick
      end
      object BitBtn2: TBitBtn
        Tag = 2
        AlignWithMargins = True
        Left = 144
        Top = 4
        Width = 74
        Height = 33
        Align = alLeft
        Cancel = True
        Caption = 'Post'
        NumGlyphs = 2
        TabOrder = 1
        OnClick = btngetClick
      end
      object btnDelete: TBitBtn
        Tag = 4
        AlignWithMargins = True
        Left = 304
        Top = 4
        Width = 74
        Height = 33
        Align = alLeft
        Cancel = True
        Caption = 'Delete'
        NumGlyphs = 2
        TabOrder = 2
        OnClick = btngetClick
      end
      object BitBtn1: TBitBtn
        Tag = 3
        AlignWithMargins = True
        Left = 224
        Top = 4
        Width = 74
        Height = 33
        Align = alLeft
        Cancel = True
        Caption = 'Put'
        NumGlyphs = 2
        TabOrder = 3
        OnClick = btngetClick
      end
    end
  end
  object Panel3: TPanel
    Left = 10
    Top = 109
    Width = 1011
    Height = 584
    Align = alClient
    Caption = 'Panel3'
    TabOrder = 1
    object Panel4: TPanel
      Left = 1
      Top = 1
      Width = 1009
      Height = 582
      Align = alClient
      TabOrder = 0
      object Image1: TImage
        Left = 724
        Top = 121
        Width = 189
        Height = 196
        Center = True
        Proportional = True
        Stretch = True
      end
      object Label2: TLabel
        Left = 728
        Top = 80
        Width = 196
        Height = 13
        Caption = 'Clique no usu'#225'rio para obter seu Avatar:'
      end
      object Label3: TLabel
        Left = 724
        Top = 323
        Width = 189
        Height = 16
        Alignment = taCenter
        AutoSize = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object mmStatus: TMemo
        Left = 1
        Top = 1
        Width = 1007
        Height = 52
        Align = alTop
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        Lines.Strings = (
          'Memo1')
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
      end
      object mmResultJson: TMemo
        Left = 1
        Top = 380
        Width = 1007
        Height = 201
        Align = alBottom
        Color = clSilver
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        Lines.Strings = (
          'Memo1')
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 1
      end
      object pnlResultado: TPanel
        Left = 1
        Top = 53
        Width = 1007
        Height = 21
        Align = alTop
        Caption = 'Servidor conectado com exito'
        Color = clLime
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 2
      end
      object mmItensJson: TMemo
        Left = 1
        Top = 74
        Width = 312
        Height = 306
        Align = alLeft
        Color = clInfoBk
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        Lines.Strings = (
          'mmItensJson')
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 3
      end
      object ListView1: TListView
        Left = 313
        Top = 74
        Width = 328
        Height = 306
        Align = alLeft
        Columns = <
          item
            Caption = 'Usuario'
            Width = 100
          end
          item
            Caption = 'Avatar'
            Width = 200
          end>
        TabOrder = 4
        ViewStyle = vsReport
        OnClick = ListView1Click
      end
    end
  end
  object ActivityIndicator1: TActivityIndicator
    Left = 164
    Top = 332
    IndicatorSize = aisXLarge
  end
  object RESTClient1: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'utf-8, *;q=0.8'
    BaseURL = 'https://api.github.com/search/repositories?q=users'
    Params = <>
    Left = 252
    Top = 268
  end
  object RESTRequest1: TRESTRequest
    Client = RESTClient1
    Params = <>
    Response = RESTResponse1
    SynchronizedEvents = False
    Left = 252
    Top = 320
  end
  object RESTResponse1: TRESTResponse
    ContentType = 'application/json'
    Left = 252
    Top = 364
  end
  object NetHTTPClient1: TNetHTTPClient
    Asynchronous = False
    ConnectionTimeout = 60000
    ResponseTimeout = 60000
    HandleRedirects = True
    AllowCookies = True
    UserAgent = 'Embarcadero URI Client/1.0'
    Left = 508
    Top = 356
  end
end
