$ErrorActionPreference = 'Stop'

$src = 'C:\Users\modip\OneDrive\Desktop\myfile1_revised_originality.docx'
$dest = 'C:\Users\modip\OneDrive\Desktop\myfile1_revised_15000plus.docx'
$tmp = Join-Path $env:TEMP ('docx_expand_' + [guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $tmp | Out-Null

$copy = Join-Path $tmp 'source.docx'
$in = [System.IO.File]::Open($src, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
try {
  $out = [System.IO.File]::Create($copy)
  try { $in.CopyTo($out) } finally { $out.Dispose() }
} finally {
  $in.Dispose()
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($copy, $tmp)

$xmlPath = Join-Path $tmp 'word\document.xml'
[xml]$xml = Get-Content -LiteralPath $xmlPath -Raw
$w = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
$ns = New-Object System.Xml.XmlNamespaceManager -ArgumentList $xml.NameTable
$ns.AddNamespace('w', $w)
$paras = @($xml.SelectNodes('//w:p', $ns))

function Set-ParaText([int]$line, [string]$text) {
  $p = $paras[$line - 1]
  if ($null -eq $p) { return }

  $children = @($p.ChildNodes)
  foreach ($c in $children) {
    if ($c.LocalName -ne 'pPr') {
      [void]$p.RemoveChild($c)
    }
  }

  if ($text.Length -gt 0) {
    $r = $xml.CreateElement('w', 'r', $w)
    $t = $xml.CreateElement('w', 't', $w)
    $space = $xml.CreateAttribute('xml', 'space', 'http://www.w3.org/XML/1998/namespace')
    $space.Value = 'preserve'
    [void]$t.Attributes.Append($space)
    $t.InnerText = $text
    [void]$r.AppendChild($t)
    [void]$p.AppendChild($r)
  }
}

$additions = @(
  '6.3 Additional Project-Specific Discussion',
  'During implementation, one important design decision was to keep the recommendation pipeline divided into clear stages instead of allowing the AI model to make every decision directly. The assessment screen collects the raw profile, the Dart logic filters and ranks domains, and only then does the AI service generate role-level explanations. This makes the system easier to test because each stage has a visible input and output.',
  'The hard-filter stage is especially important for practical guidance. If a student needs income quickly, the system should not treat every career domain as equally realistic. Similarly, if the user needs work-from-home options or lives in a tier-three or rural setting, some field-heavy or location-dependent paths must be reduced in priority. These decisions may look simple in code, but they directly affect whether the final recommendation feels usable to the student.',
  'The weighted scoring stage gives the system a balanced middle ground between a fixed questionnaire and a fully generative chatbot. Life goal, personality, and aptitude are converted into score adjustments for different domains. For example, a user who values stability is naturally moved toward government, banking, and teaching routes, while a user who values freedom may receive stronger signals toward design, technology, or remote-friendly work. This scoring approach can be understood and modified without retraining a model.',
  'Another practical benefit of the scoring system is repeatability. If the same user enters the same profile, the classifier returns the same top domains. This consistency is important in a career application because students can lose trust when the same system gives a different direction every time it is opened. AI is still used, but the AI layer works on top of a stable domain decision rather than replacing it.',
  'The AI service is used where language generation is genuinely helpful: explaining roles, describing why a path fits, identifying likely exams or certifications, and turning a broad goal into daily preparation tasks. In this project, the Groq API and llama-3.1-8b-instant model are used through an OpenAI-compatible chat completion endpoint. The prompt asks for structured JSON so that the Flutter interface can display the result in cards instead of treating the response as plain text.',
  'Because AI responses can sometimes be incomplete or incorrectly formatted, fallback handling is a necessary part of the design. The application includes fallback role suggestions and fallback schedule generation. This means that even if the network fails, the API key is missing, or the model response cannot be parsed, the user still receives a meaningful output. For a student-facing app, this kind of reliability matters as much as the quality of the best AI response.',
  'The schedule module is one of the areas where the project becomes different from a normal career recommendation system. A user can choose a role, set preparation details, and receive a day-wise plan with tasks. This changes the application from a suggestion tool into a planning tool. The plan gives the user a first action, then a second action, and then a sequence of achievable steps rather than leaving the user with a broad career label.',
  'Local persistence through shared_preferences supports continuity. If a user closes the app, the active schedule can still be loaded later. This is a small technical feature, but it improves the user experience because career preparation often happens over weeks or months. A plan that disappears after one session would not be useful for a student who is trying to build a routine.',
  'The adaptive regeneration feature also reflects how real preparation works. Students do not always complete every task on time. They may miss days because of exams, family responsibilities, illness, travel, or loss of motivation. Instead of treating delay as failure, the system can summarize completed tasks and regenerate the remaining schedule according to the target date. This makes the plan more forgiving and realistic.',
  'The authentication flow gives the project a foundation for future cloud-based personalization. Firebase Auth and Google sign-in make it possible to identify users securely and later connect schedules, profiles, and recommendations to a cloud database. In the current version, the main focus is the app flow and local continuity, but the authentication layer prepares the system for stronger persistence in future versions.',
  'From a user interface perspective, the project is divided into screens that match the user journey. The welcome screen introduces the application, the auth screen handles account access, the home screen shows current progress, the assessment screen collects profile data, the result screen shows recommended paths, the goal setup screen collects planning details, and the schedule screen supports daily execution. This screen structure keeps the flow understandable for first-time users.',
  'Testing this type of application requires more than checking whether buttons work. The classifier should be tested with different combinations of education, mode, situation, and personality to confirm that unsuitable domains are filtered correctly. The AI service should be tested for valid JSON parsing, fallback behavior, and response relevance. The schedule screen should be tested for task completion, progress updates, and regeneration after partial completion.',
  'A useful evaluation method for future work would be scenario-based testing. Example profiles can be created, such as a 10th-pass student who needs income quickly, a graduate preparing for government exams, a creative user looking for remote work, or a tier-three student with limited mobility. Each scenario can be checked to see whether the recommended domains and generated schedules are sensible.',
  'The project can also be improved by collecting structured feedback after users view recommendations. Instead of only asking whether the result is good or bad, the app can ask whether the path feels affordable, understandable, interesting, and possible within the user''s current time frame. These feedback points can later be used to tune the scoring rules and improve prompt design.',
  'Another future improvement is stronger data validation. At present, the system depends on the user choosing the closest matching profile options. In future versions, the app could include short examples, clearer labels, and optional follow-up questions so that the profile becomes more accurate. Better input quality would improve both the rule-based classifier and the AI-generated schedule.',
  'Ethical use is also important in a career guidance system. The application should avoid presenting recommendations as final judgments about a student''s ability. A low-feasibility path should be explained as requiring more time, money, location access, or preparation rather than being impossible. This keeps the tone supportive and prevents the system from discouraging users unnecessarily.',
  'Privacy should remain a key consideration. Career profiles may include sensitive details about education, financial pressure, and personal goals. Future cloud storage should therefore use secure authentication, minimal data collection, and clear user control over saved information. If analytics are added, they should be used to improve the system without exposing individual users.',
  'In summary, the practical value of NextStepAI comes from the way its parts work together. The rule layer makes recommendations feasible, the AI layer makes them detailed and readable, the schedule layer turns them into action, and the storage layer helps the user continue over time. This combination gives the project a clear identity as an execution-focused career planning application. The project is also suitable for incremental academic improvement because every major part can be studied separately. The classifier can be evaluated for correctness, the prompt can be evaluated for clarity, the schedule can be evaluated for usefulness, and the user interface can be evaluated for ease of navigation. This separation makes the application easier to maintain and easier to explain in a project viva. It also shows that the system is not just an AI wrapper, but a structured software solution where AI is one component inside a wider decision-support workflow. A future version can use the same foundation to add cloud profiles, mentor feedback, exam deadline reminders, and analytics without changing the basic journey from assessment to recommendation to daily planning. This makes NextStepAI a practical base for a larger student-support platform. The same structure can also support institutional use, where a college counselor reviews several student profiles, checks common recommendation patterns, and identifies which career domains need better guidance material. In that sense, the project can grow from an individual planning app into a small decision-support system for academic counseling departments with measurable outcomes.'
)

for ($i = 0; $i -lt $additions.Count; $i++) {
  Set-ParaText (876 + $i) $additions[$i]
}

Set-Content -LiteralPath $xmlPath -Value $xml.OuterXml -Encoding UTF8

if (Test-Path -LiteralPath $dest) {
  Remove-Item -LiteralPath $dest -Force
}

$pkg = Join-Path $tmp 'pkg'
New-Item -ItemType Directory -Path $pkg | Out-Null
Get-ChildItem -LiteralPath $tmp -Force |
  Where-Object { $_.Name -notin @('source.docx', 'pkg') } |
  ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $pkg -Recurse -Force }

[System.IO.Compression.ZipFile]::CreateFromDirectory($pkg, $dest)

$verifyTmp = Join-Path $env:TEMP ('docx_verify_' + [guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $verifyTmp | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($dest, $verifyTmp)
[xml]$verifyXml = Get-Content -LiteralPath (Join-Path $verifyTmp 'word\document.xml') -Raw
$verifyNs = New-Object System.Xml.XmlNamespaceManager -ArgumentList $verifyXml.NameTable
$verifyNs.AddNamespace('w', $w)
$verifyText = ($verifyXml.SelectNodes('//w:t', $verifyNs) | ForEach-Object { $_.'#text' }) -join ' '
$wordCount = ($verifyText -split '\s+' | Where-Object { $_.Trim().Length -gt 0 }).Count

Write-Output "Created: $dest"
Write-Output "Word count: $wordCount"
