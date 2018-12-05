# Connection
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
$api_key = 'FRESHSERVICE API KEY'
$encoded_credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $api_key, $null)))
$http_headers = @{}
$http_headers.add('Authorization', ("Basic {0}" -f $encoded_credentials))
$http_headers.add('Content-Type', 'application/json')

# API Connection URI
$portal = 'WEBSITE'
$uri = 'https://' + $portal + '.freshservice.com/api/v2/requesters'

$list_of_all_requesters = Invoke-RestMethod -Method Get -Uri $uri -Headers $http_headers
$table_of_requesters = $list_of_all_requesters | Select-Object -ExpandProperty requesters
$json_language_config = (Get-Content -Raw -Path '.\location_settings.json') | ConvertFrom-Json

foreach ($requester in $table_of_requesters)
{
    $requester_profile_uri = 'https://' + $portal + '.freshservice.com/itil/requesters/' + $requester.id + '.json'
    $requester_profile = Invoke-RestMethod -Method Get -Uri $requester_profile_uri -Headers $http_headers
    $requester_profile = $requester_profile | Select-Object -ExpandProperty user

    if ($requester_profile.created_at -eq $requester_profile.updated_at)
    {
        $user_attributes = @{}
        foreach ($user_location in $json_language_config.language_settings)
        {
            if ($requester_profile.location_name -eq $user_location.location)
            {
                $user_attributes.add('language', $user_location.language)
                $user_attributes.add('time_zone', $user_location.timezone)
                $user_attributes = @{'user' = $user_attributes}

                $json = $user_attributes | ConvertTo-Json
                Invoke-RestMethod -Method put -Uri $requester_profile_uri -Headers $http_headers -Body $json
            }
        }
    }
}
