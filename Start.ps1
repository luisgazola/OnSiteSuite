# Compatibility launcher for users of FieldServiceToolkit's former Start.ps1.
# Does not start a separate application: forwards to OnSiteSuite v2.0.
& (Join-Path $PSScriptRoot 'OnSiteSuite.ps1') @args
