object dtmCnx: TdtmCnx
  Height = 228
  Width = 542
  object cnxDatabase: TFDConnection
    Params.Strings = (
      'Database=database.db'
      'StringFormat=Unicode'
      'DateTimeFormat=DateTime'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 40
    Top = 16
  end
  object qryListaProj: TFDQuery
    Connection = cnxDatabase
    SQL.Strings = (
      'SELECT'
      '   IDPROJETO,'
      '   CAST(NOMEPROJ AS VARCHAR(100)) AS NOMEPROJ,'
      '   CAST(CAMINHOPROJ AS VARCHAR(500)) AS CAMINHOPROJ'
      'FROM TBLCDSPROJ0'
      'ORDER BY'
      '   IDPROJETO')
    Left = 40
    Top = 88
    object qryListaProjIDPROJETO: TFDAutoIncField
      FieldName = 'IDPROJETO'
      Origin = 'IDPROJETO'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object qryListaProjNOMEPROJ: TWideStringField
      AutoGenerateValue = arDefault
      FieldName = 'NOMEPROJ'
      Origin = 'NOMEPROJ'
      ProviderFlags = []
      ReadOnly = True
      Size = 100
    end
    object qryListaProjCAMINHOPROJ: TWideStringField
      AutoGenerateValue = arDefault
      FieldName = 'CAMINHOPROJ'
      Origin = 'CAMINHOPROJ'
      ProviderFlags = []
      ReadOnly = True
      Size = 500
    end
  end
end
