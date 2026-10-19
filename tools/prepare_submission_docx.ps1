param(
  [Parameter(Mandatory=$true)][string]$InputPath,
  [Parameter(Mandatory=$true)][string]$OutputPath
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Read-ZipEntryText {
  param($Zip, [string]$Name)
  $entry = $Zip.GetEntry($Name)
  if ($null -eq $entry) { return $null }
  $reader = [System.IO.StreamReader]::new($entry.Open())
  $text = $reader.ReadToEnd()
  $reader.Close()
  return $text
}

function Write-ZipEntryText {
  param($Zip, [string]$Name, [string]$Text)
  $old = $Zip.GetEntry($Name)
  if ($null -ne $old) { $old.Delete() }
  $entry = $Zip.CreateEntry($Name, [System.IO.Compression.CompressionLevel]::Optimal)
  $stream = $entry.Open()
  $bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($Text)
  $stream.Write($bytes, 0, $bytes.Length)
  $stream.Close()
}

function Save-XmlToString {
  param([xml]$Xml)
  $ms = [System.IO.MemoryStream]::new()
  $settings = [System.Xml.XmlWriterSettings]::new()
  $settings.Encoding = [System.Text.UTF8Encoding]::new($false)
  $settings.OmitXmlDeclaration = $false
  $writer = [System.Xml.XmlWriter]::Create($ms, $settings)
  $Xml.Save($writer)
  $writer.Close()
  $text = [System.Text.UTF8Encoding]::new($false).GetString($ms.ToArray())
  $ms.Dispose()
  return $text
}

function Ensure-Child {
  param(
    [System.Xml.XmlElement]$Parent,
    [string]$Prefix,
    [string]$LocalName,
    [string]$Namespace
  )
  $child = $Parent.ChildNodes | Where-Object { $_.LocalName -eq $LocalName -and $_.NamespaceURI -eq $Namespace } | Select-Object -First 1
  if ($null -eq $child) {
    $child = $Parent.OwnerDocument.CreateElement($Prefix, $LocalName, $Namespace)
    [void]$Parent.AppendChild($child)
  }
  return $child
}

function Set-WAttr {
  param(
    [System.Xml.XmlElement]$Element,
    [string]$LocalName,
    [string]$Value
  )
  $attr = $Element.OwnerDocument.CreateAttribute('w', $LocalName, 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
  $attr.Value = $Value
  [void]$Element.Attributes.SetNamedItem($attr)
}

function Set-RAttr {
  param(
    [System.Xml.XmlElement]$Element,
    [string]$LocalName,
    [string]$Value
  )
  $attr = $Element.OwnerDocument.CreateAttribute('r', $LocalName, 'http://schemas.openxmlformats.org/officeDocument/2006/relationships')
  $attr.Value = $Value
  [void]$Element.Attributes.SetNamedItem($attr)
}

function Set-ParagraphText {
  param(
    [System.Xml.XmlElement]$Paragraph,
    [System.Xml.XmlNamespaceManager]$Ns,
    [string]$NewText
  )

  $textNodes = @($Paragraph.SelectNodes('.//w:t', $Ns))
  if ($textNodes.Count -eq 0) { return }
  $textNodes[0].InnerText = $NewText
  $spaceAttr = $textNodes[0].OwnerDocument.CreateAttribute('xml', 'space', 'http://www.w3.org/XML/1998/namespace')
  $spaceAttr.Value = 'preserve'
  [void]$textNodes[0].Attributes.SetNamedItem($spaceAttr)
  for ($i = 1; $i -lt $textNodes.Count; $i++) {
    $textNodes[$i].InnerText = ''
  }
}

function Polish-Text {
  param([string]$Text)

  $t = $Text.Trim()
  if ($t.Length -eq 0) { return $Text }

  $pairs = @(
    @('In partial fulfilment of the requirement for the award of degree of', 'In partial fulfillment of the requirement for the award of degree of'),
    @('deliver accurate and guidance that reflects the user context', 'deliver accurate, context-aware guidance'),
    @('guidance that reflects the user context', 'context-aware guidance'),
    @('lack of individual guidance', 'lack of personalized guidance'),
    @('career choice has evolved into a highly complex and critical choice process', 'career planning has become a complex and important process'),
    @('This ensures a transparent and interpretable choice process.', 'This keeps the recommendation process transparent and easy to interpret.'),
    @('decision-making process', 'decision-making process'),
    @('choice process', 'decision process'),
    @('Within the application design, in addition to career identification,', 'In addition to career identification,'),
    @('From a practical implementation view, in addition to career identification,', 'In addition to career identification,'),
    @('NextStepAI not merely assists', 'NextStepAI does not merely assist'),
    @('the application not merely', 'the application does not merely'),
    @('not merely helps', 'does not merely help'),
    @('not merely suggests', 'does not merely suggest'),
    @('not merely provides', 'does not merely provide'),
    @('not merely based', 'not only based'),
    @('ready for expansion', 'scalable'),
    @('rounded support model', 'well-rounded support model'),
    @('counselling', 'counseling'),
    @('behaviour', 'behavior'),
    @('behavioural', 'behavioral'),
    @('optimise', 'optimize'),
    @('organise', 'organize'),
    @('organised', 'organized'),
    @('summarise', 'summarize'),
    @('programme', 'program'),
    @('centre', 'center'),
    @('contains of numerous', 'contains numerous'),
    @('decision-tree Algorithm', 'decision-tree algorithm'),
    @('AI-based Recommendation Algorithm', 'AI-based recommendation algorithm'),
    @('Use in this project:The', 'Use in this project: The'),
    @('Usefulness in this project:', 'Usefulness in this project: '),
    @('Relevance to NextStepAI: ', 'Relevance to NextStepAI: '),
    @('career suggestions.the application may generate less accurate or unsuitable.', 'the application may generate career suggestions that are less accurate or unsuitable.'),
    @('career suggestions.the system may generate less accurate or unsuitable.', 'the application may generate career suggestions that are less accurate or unsuitable.'),
    @('Title of Project Report“A', 'Title of Project Report “A'),
    @('Priyvrat Modiof', 'Priyvrat Modi of'),
    @('Carrer', 'Career'),
    @('INTRODUCTIONTOTHETOPIC', 'INTRODUCTION TO THE TOPIC'),
    @('RESEARCHOBJECTIVES AND METHODLOGY', 'RESEARCH OBJECTIVES AND METHODOLOGY'),
    @('METHODOIOGY', 'METHODOLOGY')
  )

  foreach ($pair in $pairs) {
    $t = $t.Replace($pair[0], $pair[1])
  }

  $t = $t -replace '\s+', ' '
  $t = $t -replace '\bthe application does not merely assists\b', 'the application does not merely assist'
  $t = $t -replace '\bdoes not merely assists\b', 'does not merely assist'
  $t = $t -replace 'AI-based\s+Recommendation\s+Algorithm', 'AI-based recommendation algorithm'
  $t = $t -replace '\bhas significantly increased\b', 'have significantly increased'
  $t = $t -replace '\bFurther, each\b', 'Each'
  return $t
}

$outDir = Split-Path -Parent $OutputPath
if (!(Test-Path -LiteralPath $outDir)) {
  New-Item -ItemType Directory -Path $outDir | Out-Null
}

Copy-Item -LiteralPath $InputPath -Destination $OutputPath -Force

$fs = [System.IO.File]::Open($OutputPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
$zip = [System.IO.Compression.ZipArchive]::new($fs, [System.IO.Compression.ZipArchiveMode]::Update)

$docText = Read-ZipEntryText -Zip $zip -Name 'word/document.xml'
[xml]$doc = $docText
$ns = [System.Xml.XmlNamespaceManager]::new($doc.NameTable)
$ns.AddNamespace('w', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
$ns.AddNamespace('r', 'http://schemas.openxmlformats.org/officeDocument/2006/relationships')

$paragraphsChanged = 0
foreach ($p in $doc.SelectNodes('//w:body/w:p', $ns)) {
  $current = (($p.SelectNodes('.//w:t', $ns) | ForEach-Object { $_.'#text' }) -join '')
  if ($current.Trim().Length -eq 0) { continue }
  $polished = Polish-Text -Text $current
  if ($polished -ne $current) {
    Set-ParagraphText -Paragraph $p -Ns $ns -NewText $polished
    $paragraphsChanged++
  }
}

$wNs = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
foreach ($p in $doc.SelectNodes('//w:body/w:p', $ns)) {
  $pPr = Ensure-Child -Parent $p -Prefix 'w' -LocalName 'pPr' -Namespace $wNs
  $spacing = Ensure-Child -Parent $pPr -Prefix 'w' -LocalName 'spacing' -Namespace $wNs
  Set-WAttr -Element $spacing -LocalName 'line' -Value '480'
  Set-WAttr -Element $spacing -LocalName 'lineRule' -Value 'auto'
  Set-WAttr -Element $spacing -LocalName 'before' -Value '0'
  Set-WAttr -Element $spacing -LocalName 'after' -Value '0'
}

foreach ($r in $doc.SelectNodes('//w:r', $ns)) {
  $rPr = Ensure-Child -Parent $r -Prefix 'w' -LocalName 'rPr' -Namespace $wNs
  $rFonts = Ensure-Child -Parent $rPr -Prefix 'w' -LocalName 'rFonts' -Namespace $wNs
  Set-WAttr -Element $rFonts -LocalName 'ascii' -Value 'Times New Roman'
  Set-WAttr -Element $rFonts -LocalName 'hAnsi' -Value 'Times New Roman'
  Set-WAttr -Element $rFonts -LocalName 'cs' -Value 'Times New Roman'
  $sz = Ensure-Child -Parent $rPr -Prefix 'w' -LocalName 'sz' -Namespace $wNs
  Set-WAttr -Element $sz -LocalName 'val' -Value '24'
  $szCs = Ensure-Child -Parent $rPr -Prefix 'w' -LocalName 'szCs' -Namespace $wNs
  Set-WAttr -Element $szCs -LocalName 'val' -Value '24'
}

foreach ($szNode in $doc.SelectNodes('//w:sz|//w:szCs', $ns)) {
  Set-WAttr -Element $szNode -LocalName 'val' -Value '24'
}

foreach ($sectPr in $doc.SelectNodes('//w:sectPr', $ns)) {
  $pgMar = Ensure-Child -Parent $sectPr -Prefix 'w' -LocalName 'pgMar' -Namespace $wNs
  Set-WAttr -Element $pgMar -LocalName 'top' -Value '1440'
  Set-WAttr -Element $pgMar -LocalName 'right' -Value '1440'
  Set-WAttr -Element $pgMar -LocalName 'bottom' -Value '1440'
  Set-WAttr -Element $pgMar -LocalName 'left' -Value '1440'
  Set-WAttr -Element $pgMar -LocalName 'header' -Value '720'
  Set-WAttr -Element $pgMar -LocalName 'footer' -Value '720'
  Set-WAttr -Element $pgMar -LocalName 'gutter' -Value '0'
}

$relsText = Read-ZipEntryText -Zip $zip -Name 'word/_rels/document.xml.rels'
$headerRelId = 'rId999'
if ($null -ne $relsText) {
  [xml]$rels = $relsText
  $relNs = 'http://schemas.openxmlformats.org/package/2006/relationships'
  $existingHeader = $rels.Relationships.Relationship | Where-Object { $_.Target -eq 'header1.xml' } | Select-Object -First 1
  if ($null -ne $existingHeader) {
    $headerRelId = $existingHeader.Id
  } else {
    $maxRid = 0
    foreach ($rel in $rels.Relationships.Relationship) {
      if ($rel.Id -match '^rId(\d+)$') {
        $maxRid = [math]::Max($maxRid, [int]$Matches[1])
      }
    }
    $headerRelId = 'rId' + ($maxRid + 1)
    $newRel = $rels.CreateElement('Relationship', $relNs)
    $idAttr = $rels.CreateAttribute('Id')
    $idAttr.Value = $headerRelId
    [void]$newRel.Attributes.SetNamedItem($idAttr)
    $typeAttr = $rels.CreateAttribute('Type')
    $typeAttr.Value = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/header'
    [void]$newRel.Attributes.SetNamedItem($typeAttr)
    $targetAttr = $rels.CreateAttribute('Target')
    $targetAttr.Value = 'header1.xml'
    [void]$newRel.Attributes.SetNamedItem($targetAttr)
    [void]$rels.DocumentElement.AppendChild($newRel)
    Write-ZipEntryText -Zip $zip -Name 'word/_rels/document.xml.rels' -Text (Save-XmlToString -Xml $rels)
  }
}

foreach ($sectPr in $doc.SelectNodes('//w:sectPr', $ns)) {
  $defaultHeader = $sectPr.SelectSingleNode('w:headerReference[@w:type="default"]', $ns)
  if ($null -eq $defaultHeader) {
    $defaultHeader = $doc.CreateElement('w', 'headerReference', $wNs)
    Set-WAttr -Element $defaultHeader -LocalName 'type' -Value 'default'
    Set-RAttr -Element $defaultHeader -LocalName 'id' -Value $headerRelId
    [void]$sectPr.PrependChild($defaultHeader)
  } else {
    Set-RAttr -Element $defaultHeader -LocalName 'id' -Value $headerRelId
  }
}

$headerXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:hdr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <w:p>
    <w:pPr>
      <w:jc w:val="right"/>
      <w:spacing w:line="480" w:lineRule="auto" w:before="0" w:after="0"/>
    </w:pPr>
    <w:r>
      <w:rPr>
        <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
        <w:sz w:val="24"/>
        <w:szCs w:val="24"/>
      </w:rPr>
      <w:t>Running head: NEXTSTEPAI</w:t>
    </w:r>
  </w:p>
</w:hdr>
'@
Write-ZipEntryText -Zip $zip -Name 'word/header1.xml' -Text $headerXml

$contentTypesText = Read-ZipEntryText -Zip $zip -Name '[Content_Types].xml'
if ($null -ne $contentTypesText) {
  [xml]$contentTypes = $contentTypesText
  $ctNs = 'http://schemas.openxmlformats.org/package/2006/content-types'
  $exists = $false
  foreach ($override in $contentTypes.Types.Override) {
    if ($override.PartName -eq '/word/header1.xml') { $exists = $true }
  }
  if (!$exists) {
    $newOverride = $contentTypes.CreateElement('Override', $ctNs)
    $partAttr = $contentTypes.CreateAttribute('PartName')
    $partAttr.Value = '/word/header1.xml'
    [void]$newOverride.Attributes.SetNamedItem($partAttr)
    $contentTypeAttr = $contentTypes.CreateAttribute('ContentType')
    $contentTypeAttr.Value = 'application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml'
    [void]$newOverride.Attributes.SetNamedItem($contentTypeAttr)
    [void]$contentTypes.DocumentElement.AppendChild($newOverride)
    Write-ZipEntryText -Zip $zip -Name '[Content_Types].xml' -Text (Save-XmlToString -Xml $contentTypes)
  }
}

$documentOut = Save-XmlToString -Xml $doc
$documentOut = $documentOut.Replace('AI-based Recommendation Algorithm', 'AI-based recommendation algorithm')
Write-ZipEntryText -Zip $zip -Name 'word/document.xml' -Text $documentOut

$stylesText = Read-ZipEntryText -Zip $zip -Name 'word/styles.xml'
if ($null -ne $stylesText) {
  [xml]$styles = $stylesText
  $styleNs = [System.Xml.XmlNamespaceManager]::new($styles.NameTable)
  $styleNs.AddNamespace('w', $wNs)
  foreach ($style in $styles.SelectNodes('//w:style', $styleNs)) {
    $rPr = Ensure-Child -Parent $style -Prefix 'w' -LocalName 'rPr' -Namespace $wNs
    $rFonts = Ensure-Child -Parent $rPr -Prefix 'w' -LocalName 'rFonts' -Namespace $wNs
    Set-WAttr -Element $rFonts -LocalName 'ascii' -Value 'Times New Roman'
    Set-WAttr -Element $rFonts -LocalName 'hAnsi' -Value 'Times New Roman'
    Set-WAttr -Element $rFonts -LocalName 'cs' -Value 'Times New Roman'
  }
  foreach ($szNode in $styles.SelectNodes('//w:sz|//w:szCs', $styleNs)) {
    Set-WAttr -Element $szNode -LocalName 'val' -Value '24'
  }
  Write-ZipEntryText -Zip $zip -Name 'word/styles.xml' -Text (Save-XmlToString -Xml $styles)
}

$zip.Dispose()
$fs.Dispose()

Write-Output "Polished paragraphs: $paragraphsChanged"
Write-Output $OutputPath
