Add-Type -AssemblyName System.Drawing
Get-ChildItem 'F:\DeltaRobot\MoPhong_Ben\figs\*.bmp' | ForEach-Object {
  $png = [IO.Path]::ChangeExtension($_.FullName,'png')
  $img = [System.Drawing.Image]::FromFile($_.FullName)
  $img.Save($png,[System.Drawing.Imaging.ImageFormat]::Png)
  $img.Dispose()
  Write-Host "$($_.Name) -> $([IO.Path]::GetFileName($png))  ($([math]::Round((Get-Item $png).Length/1kb)) KB)"
}
