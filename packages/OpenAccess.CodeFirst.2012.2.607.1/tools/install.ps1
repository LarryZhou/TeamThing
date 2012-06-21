param($installPath, $toolsPath, $package, $project)

# This is the MSBuild targets file to add
$targetsFile = [System.IO.Path]::Combine($toolsPath, 'enhancer\OpenAccess.targets')

# Copy the OpenAccess API assembly to the enhancer directory for easy resolution
[System.IO.File]::Copy([System.IO.Path]::Combine($installPath, 'lib\Telerik.OpenAccess.dll'), [System.IO.Path]::Combine($toolsPath, 'enhancer\Telerik.OpenAccess.dll'))

# Need to load MSBuild assembly if it's not loaded yet.
Add-Type -AssemblyName 'Microsoft.Build, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'
# Grab the loaded MSBuild project for the project
$msbuild = [Microsoft.Build.Evaluation.ProjectCollection]::GlobalProjectCollection.GetLoadedProjects($project.FullName) | Select-Object -First 1

# Make the path to the targets file relative.
$projectUri = new-object Uri('file://' + $project.FullName)
$targetUri = new-object Uri('file://' + $targetsFile)
$relativePath = $projectUri.MakeRelativeUri($targetUri).ToString().Replace([System.IO.Path]::AltDirectorySeparatorChar, [System.IO.Path]::DirectorySeparatorChar)

#Add the enhancer item definition
$msbuild.Xml.AddProperty('EnhancerAssembly','enhancer.exe') | out-null

# Add the import 
$msbuild.Xml.AddImport($relativePath) | out-null

# Save the project
$project.Save()
