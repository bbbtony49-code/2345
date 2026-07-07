$files = Get-ChildItem -Recurse -Filter *.html

$functionCode = @"

<script>
function gtag_report_conversion(url) {
    var callback = function () {
        if (typeof(url) != 'undefined') {
            window.location = url;
        }
    };
    gtag('event', 'conversion', {
        'send_to': 'AW-11459072287/OO6CCLSOzcgcEJ-ijtgq',
        'event_callback': callback
    });
    return false;
}
</script>

"@

foreach ($file in $files) {

    $text = Get-Content $file.FullName -Raw -Encoding UTF8

    # 加入 gtag_report_conversion（只加入一次）
    if ($text.Contains("gtag('config', 'AW-11459072287');") -and
        -not $text.Contains("function gtag_report_conversion")) {

        $text = $text.Replace(
            "gtag('config', 'AW-11459072287');",
            "gtag('config', 'AW-11459072287');`r`n$functionCode"
        )
    }

    # 電話按鈕
    $text = $text.Replace(
        'href="tel:0911247783"',
        'href="tel:0911247783" onclick="return gtag_report_conversion(''tel:0911247783'');"'
    )

    # LINE 按鈕
    $text = $text.Replace(
        'href="https://line.me/ti/p/RTufr7jL8G"',
        'href="https://line.me/ti/p/RTufr7jL8G" onclick="return gtag_report_conversion(''https://line.me/ti/p/RTufr7jL8G'');"'
    )

    Set-Content $file.FullName -Value $text -Encoding UTF8

    Write-Host "已修改：" $file.Name
}

Write-Host ""
Write-Host "======================================"
Write-Host "Done!"
Write-Host "======================================"