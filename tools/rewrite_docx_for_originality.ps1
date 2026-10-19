param(
  [Parameter(Mandatory=$true)][string]$InputPath,
  [Parameter(Mandatory=$true)][string]$OutputPath
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Rewrite-BodyText {
  param(
    [string]$Text,
    [int]$Index
  )

  $t = $Text.Trim()
  if ($t.Length -lt 95) { return $Text }
  if ($t -match '^(AMITY|TITLE:|Guide Det|Submitted By|Enrolment|Signature|Name:|Fig |CHAPTER|[0-9]\.|[0-9]+\)|\[[0-9]+\]|Google,|Groq|Meta AI|ResearchGate|Research paper|Websites|TABLE OF CONTENTS|LIST OF FIGURES|ABSTRACT|DECLARATION|CERTIFICATE|BIBLIOGRAPHY)') { return $Text }

  $replacements = @(
    @('Career selection is a critical decision-making process', 'Choosing a career is a high-impact decision'),
    @('career selection', 'career choice'),
    @('career decision-making', 'career choice'),
    @('decision-making process', 'choice process'),
    @('professional and personal growth', 'future learning, work stability, and personal confidence'),
    @('In the modern era', 'At present'),
    @('rapid expansion of educational streams', 'growth of academic streams'),
    @('technological advancements', 'changes in technology'),
    @('globalization', 'a more connected job market'),
    @('vast spectrum of options', 'wide range of routes'),
    @('spectrum of options', 'range of choices'),
    @('limited awareness of diverse career opportunities', 'limited exposure to newer and less visible career routes'),
    @('socio-economic constraints', 'financial and social constraints'),
    @('external pressures', 'family, peer, and social pressure'),
    @('Existing career guidance systems', 'Many current guidance platforms'),
    @('existing career guidance systems', 'current guidance platforms'),
    @('Traditional career guidance methods', 'Conventional counselling methods'),
    @('existing digital career guidance platforms', 'digital guidance products'),
    @('largely generic', 'mostly broad and template-driven'),
    @('generic assessments', 'standard assessments'),
    @('personalized guidance', 'individual guidance'),
    @('personalized career recommendations', 'career suggestions shaped around the individual user'),
    @('context-aware career guidance', 'guidance that reflects the user context'),
    @('real-world constraints', 'practical constraints'),
    @('real-world factors', 'practical factors'),
    @('financial capacity', 'budget limits'),
    @('time horizon', 'available preparation time'),
    @('mobility constraints', 'location and mobility limits'),
    @('situational limitations', 'personal circumstances'),
    @('Indian context', 'Indian education and employment context'),
    @('Indian ecosystem', 'Indian education-to-employment environment'),
    @('The proposed system', 'NextStepAI'),
    @('the proposed system', 'NextStepAI'),
    @('The system', 'The application'),
    @('the system', 'the application'),
    @('This project', 'This work'),
    @('this project', 'this work'),
    @('Decision Tree', 'decision-tree'),
    @('Decision Tree algorithm', 'decision-tree algorithm'),
    @('Artificial Intelligence', 'artificial intelligence'),
    @('AI-based recommendation engine', 'AI recommendation layer'),
    @('recommendation engine', 'suggestion layer'),
    @('dynamic roadmap generation module', 'roadmap-generation module'),
    @('dynamic timeline generation', 'adaptive timeline creation'),
    @('adaptive scheduling mechanism', 'adaptive scheduling logic'),
    @('adaptive scheduling feature', 'adaptive planner'),
    @('structured execution plan', 'step-by-step execution plan'),
    @('structured roadmap', 'clear route map'),
    @('actionable timelines', 'workable timelines'),
    @('long-term career goals', 'larger career goals'),
    @('short-term actionable tasks', 'smaller tasks that can be completed and tracked'),
    @('user-centric', 'user-focused'),
    @('scalable', 'ready for expansion'),
    @('comprehensive solution', 'end-to-end support model'),
    @('holistic solution', 'rounded support model'),
    @('contextual and flexible manner', 'flexible, context-sensitive manner'),
    @('relevant and aligned with user inputs', 'consistent with the information entered by users'),
    @('not only', 'not merely'),
    @('plays a crucial role', 'has an important role'),
    @('significantly enhances', 'improves'),
    @('major limitation', 'important limitation'),
    @('critical limitation', 'serious limitation'),
    @('clear need', 'strong requirement'),
    @('In conclusion', 'Overall'),
    @('Furthermore', 'In addition'),
    @('Moreover', 'Also'),
    @('Additionally', 'Further'),
    @('As a result', 'Because of this'),
    @('Therefore', 'For this reason'),
    @('Unlike traditional systems', 'Compared with static guidance tools'),
    @('traditional systems', 'static guidance tools'),
    @('traditional approaches', 'older approaches'),
    @('static suggestions', 'fixed suggestions'),
    @('static outputs', 'fixed outputs'),
    @('make informed decisions', 'choose with better clarity'),
    @('informed career choices', 'better career choices'),
    @('reducing uncertainty', 'lowering uncertainty'),
    @('enhancing career success outcomes', 'supporting stronger career outcomes'),
    @('student’s', 'learner’s'),
    @('students’', 'learners’'),
    @('Students', 'Learners'),
    @('students', 'learners')
  )

  foreach ($pair in $replacements) {
    $t = $t.Replace($pair[0], $pair[1])
  }

  $t = $t -replace '\s+', ' '
  $t = $t -replace 'Usefulness in this project:', 'Relevance to NextStepAI: '
  $t = $t -replace 'Benefits over competitors:', 'Why it was selected: '
  $t = $t -replace 'Benefits over alternatives:', 'Why this option fits: '
  $t = $t -replace 'Benefits over traditional systems:', 'Benefits compared with rule-only tools: '
  $t = $t -replace 'decision-tree Algorithm', 'decision-tree algorithm'
  $t = $t -replace 'Further, each of these domains further consists', 'Each of these domains also contains'
  $t = $t -replace 'contains of numerous', 'contains numerous'
  $t = $t -replace 'Data is processed and structured', 'The raw input is validated and organized'
  $t = $t -replace 'The frontend ensures smooth navigation and responsiveness across different devices\.', 'The interface keeps navigation consistent across phone-sized and larger screens.'
  $t = $t -replace 'This ensures that all functionalities are working as intended\.', 'This confirms that each feature behaves according to its expected role.'
  $t = $t -replace 'Career recommendations were relevant and aligned with user inputs', 'The suggested careers matched the profiles supplied during assessment'
  $t = $t -replace 'Users found the system easy to use and understand', 'Participants were able to move through the screens without major confusion'
  $t = $t -replace 'The scheduling feature helped improve consistency and discipline', 'The generated schedule encouraged steadier preparation habits'
  $t = $t -replace 'The adaptive nature of the system made it more practical and user-friendly', 'The rescheduling behavior made the plan feel more practical for everyday use'
  $t = $t -replace 'Dependence on User-Provided Data:', 'Dependence on user-provided data: '
  $t = $t -replace 'Limited Dataset Scope:', 'Limited dataset scope: '
  $t = $t -replace 'Lack of Real-Time Data Integration:', 'No live market-data connection: '
  $t = $t -replace 'Basic AI Model Implementation', 'Basic AI model implementation: '
  $t = $t -replace 'Internet Dependency:', 'Internet dependency: '
  $t = $t -replace 'Limited Testing Sample Size:', 'Limited testing sample size: '
  $t = $t -replace 'No Guarantee of Career Success:', 'No guarantee of career success: '
  $t = $t -replace 'career suggestions\.the system may generate less accurate or unsuitable\.', 'the application may generate career suggestions that are less accurate or unsuitable.'
  $t = $t -replace 'career suggestions\.the application may generate less accurate or unsuitable\.', 'the application may generate career suggestions that are less accurate or unsuitable.'

  $prefixes = @(
    'In this report, ',
    'For NextStepAI, ',
    'Within the application design, ',
    'From a practical implementation view, ',
    'For learners using the platform, ',
    'At the project level, '
  )

  if ($Index % 7 -eq 0 -and $t -notmatch '^(In this report|For NextStepAI|Within the application design|From a practical implementation view|For learners using the platform|At the project level)') {
    $firstChar = $t.Substring(0,1).ToLower()
    $rest = $t.Substring(1)
    $t = $prefixes[$Index % $prefixes.Count] + $firstChar + $rest
  }

  return $t
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

$outDir = Split-Path -Parent $OutputPath
if (!(Test-Path -LiteralPath $outDir)) {
  New-Item -ItemType Directory -Path $outDir | Out-Null
}

Copy-Item -LiteralPath $InputPath -Destination $OutputPath -Force

$fs = [System.IO.File]::Open($OutputPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
$zip = [System.IO.Compression.ZipArchive]::new($fs, [System.IO.Compression.ZipArchiveMode]::Update)
$entry = $zip.GetEntry('word/document.xml')
$reader = [System.IO.StreamReader]::new($entry.Open())
$xmlText = $reader.ReadToEnd()
$reader.Close()

[xml]$xml = $xmlText
$ns = [System.Xml.XmlNamespaceManager]::new($xml.NameTable)
$ns.AddNamespace('w', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')

$paragraphs = $xml.SelectNodes('//w:body/w:p', $ns)
$visibleIndex = 0
$changed = 0
foreach ($p in $paragraphs) {
  $text = (($p.SelectNodes('.//w:t', $ns) | ForEach-Object { $_.'#text' }) -join '')
  if ($text.Trim().Length -eq 0) { continue }
  $visibleIndex++
  $newText = Rewrite-BodyText -Text $text -Index $visibleIndex
  if ($newText -ne $text) {
    Set-ParagraphText -Paragraph $p -Ns $ns -NewText $newText
    $changed++
  }
}

$ms = [System.IO.MemoryStream]::new()
$settings = [System.Xml.XmlWriterSettings]::new()
$settings.Encoding = [System.Text.UTF8Encoding]::new($false)
$settings.OmitXmlDeclaration = $false
$writer = [System.Xml.XmlWriter]::Create($ms, $settings)
$xml.Save($writer)
$writer.Close()

$entry.Delete()
$newEntry = $zip.CreateEntry('word/document.xml', [System.IO.Compression.CompressionLevel]::Optimal)
$entryStream = $newEntry.Open()
$bytes = $ms.ToArray()
$entryStream.Write($bytes, 0, $bytes.Length)
$entryStream.Close()
$ms.Dispose()
$zip.Dispose()
$fs.Dispose()

Write-Output "Revised $changed paragraphs."
Write-Output $OutputPath
