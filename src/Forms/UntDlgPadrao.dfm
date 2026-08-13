object frmDlgPadrao: TfrmDlgPadrao
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Dialogo'
  ClientHeight = 256
  ClientWidth = 520
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object pnlFundo: TPanel
    Left = 0
    Top = 0
    Width = 520
    Height = 256
    Align = alClient
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 0
    object pnlTopo: TPanel
      Left = 0
      Top = 0
      Width = 520
      Height = 68
      Align = alTop
      BevelOuter = bvNone
      ParentBackground = False
      TabOrder = 0
      object shpIcone: TShape
        Left = 16
        Top = 16
        Width = 36
        Height = 36
        Shape = stRoundRect
      end
      object lblIcone: TLabel
        Left = 29
        Top = 21
        Width = 10
        Height = 24
        Alignment = taCenter
        AutoSize = False
        Caption = 'i'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -20
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCabecalho: TLabel
        Left = 64
        Top = 15
        Width = 430
        Height = 36
        AutoSize = False
        Caption = 'Cabe'#231'alho'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -18
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object bvlTopo: TBevel
        Left = 0
        Top = 66
        Width = 520
        Height = 2
        Align = alBottom
        Shape = bsTopLine
        ExplicitTop = 52
      end
    end
    object pnlConteudo: TPanel
      Left = 0
      Top = 68
      Width = 520
      Height = 116
      Align = alClient
      BevelOuter = bvNone
      ParentBackground = False
      TabOrder = 1
      object lblTexto: TLabel
        Left = 16
        Top = 16
        Width = 488
        Height = 44
        AutoSize = False
        Caption = 'Texto principal do di'#225'logo.'
        WordWrap = True
      end
      object pnlDetalhes: TPanel
        Left = 16
        Top = 72
        Width = 488
        Height = 84
        BevelOuter = bvNone
        ParentBackground = False
        TabOrder = 0
        object lblDetalhesTitulo: TLabel
          Left = 8
          Top = 6
          Width = 49
          Height = 15
          Caption = 'Detalhes'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object mmoDetalhes: TMemo
          Left = 8
          Top = 27
          Width = 472
          Height = 49
          BorderStyle = bsNone
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 0
        end
      end
    end
    object pnlRodape: TPanel
      Left = 0
      Top = 184
      Width = 520
      Height = 24
      Align = alBottom
      BevelOuter = bvNone
      ParentBackground = False
      TabOrder = 2
      object bvlRodape: TBevel
        Left = 0
        Top = 0
        Width = 520
        Height = 2
        Align = alTop
        Shape = bsTopLine
      end
      object lblRodape: TLabel
        Left = 16
        Top = 6
        Width = 488
        Height = 15
        AutoSize = False
        Caption = 'Rodap'#233' do di'#225'logo'
        WordWrap = True
      end
    end
    object pnlBotoes: TPanel
      Left = 0
      Top = 208
      Width = 520
      Height = 48
      Align = alBottom
      BevelOuter = bvNone
      ParentBackground = False
      TabOrder = 3
    end
  end
end
