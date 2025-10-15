param (
    [string]$MessageFile = "$PSScriptRoot\message.txt"
)

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        WindowStyle="None"
        AllowsTransparency="True"
        WindowState="Maximized"
        Topmost="False"
        ShowInTaskbar="False">
    <Window.Background>
        <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
            <GradientStop Color="#800000FF" Offset="1.0"/>
            <GradientStop Color="#804B0082" Offset="0.0"/>
        </LinearGradientBrush>
    </Window.Background>
    <Grid>
        <TextBlock Name="TopText"
                   Text="WinClick by MartyFiles"
                   FontSize="48"
                   FontWeight="Bold"
                   Foreground="White"
                   HorizontalAlignment="Center"
                   VerticalAlignment="Center"
                   Margin="0,-150,0,0"/>
				   
		<TextBlock Name="BottomText"
                   Text="t.me/martyfiles | youtube.com/martyfiles | github.com/martyfiles"
                   FontSize="20"
                   FontWeight="Thin"
                   Foreground="Gray"
                   HorizontalAlignment="Center"
                   VerticalAlignment="Center"
                   Margin="40,900,40,0"/>

        <TextBlock Name="MainMessage"
                   FontSize="36"
                   Foreground="LightGray"
                   HorizontalAlignment="Center"
                   VerticalAlignment="Center"
                   TextAlignment="Center"
                   TextWrapping="Wrap"
                   Margin="40,100,40,0"/>
    </Grid>
</Window>
"@

# Загружаем XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Находим элемент для основного текста
$mainText = $window.FindName("MainMessage")

# Функция обновления текста из файла
function Update-Message {
    if (Test-Path $MessageFile) {
        try {
            $newText = [System.IO.File]::ReadAllText($MessageFile, [System.Text.Encoding]::UTF8)
            if ($mainText.Text -ne $newText) {
                $mainText.Text = $newText
            }
        } catch {}
    }
}

# Таймер обновления сообщения каждые 300 мс
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMilliseconds(300)
$timer.Add_Tick({ Update-Message })
$timer.Start()

# Начальное обновление
Update-Message

# Импорт WinAPI
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class User32 {
    [DllImport("user32.dll")]
    public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
    [DllImport("user32.dll")]
    public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
    public const int GWL_EXSTYLE = -20;
    public const int WS_EX_TOOLWINDOW = 0x00000080;
    public const int WS_EX_TRANSPARENT = 0x00000020;
}
"@

# Установка стиля после полной инициализации окна
$window.Add_SourceInitialized({
    $hwnd = (New-Object System.Windows.Interop.WindowInteropHelper $window).Handle

    $exStyle = [User32]::GetWindowLong($hwnd, [User32]::GWL_EXSTYLE)
    $newStyle = $exStyle -bor [User32]::WS_EX_TOOLWINDOW -bor [User32]::WS_EX_TRANSPARENT
    [User32]::SetWindowLong($hwnd, [User32]::GWL_EXSTYLE, $newStyle) | Out-Null
})

# Показываем окно
$window.ShowDialog() | Out-Null
