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
    <GradientStop Color="#800000FF" Offset="1.0"/>  <!-- ����� ����� -->
    <GradientStop Color="#804B0082" Offset="0.0"/>  <!-- ���������� ������ -->
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

# ��������� XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# ������� ������� ��� ��������� ������
$mainText = $window.FindName("MainMessage")

# ������� ���������� ������ �� ����� � ������ OEM (CP866)
function Update-Message {
    if (Test-Path $MessageFile) {
        try {
            $newText = Get-Content $MessageFile -Raw -Encoding OEM -ErrorAction SilentlyContinue
            if ($mainText.Text -ne $newText) {
                $mainText.Text = $newText
            }
        } catch {}
    }
}

# ������ ���������� ��������� ������ 300 ��
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMilliseconds(300)
$timer.Add_Tick({ Update-Message })
$timer.Start()

# ��������� ����������
Update-Message

# ����������� WinAPI ��� ���������� �����
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
    public const int SWP_NOSIZE = 0x0001;
    public const int SWP_NOMOVE = 0x0002;
    public const int SWP_NOACTIVATE = 0x0010;
    public static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
}
public class User32 {
    [DllImport("user32.dll")]
    public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
    [DllImport("user32.dll")]
    public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
    public const int GWL_EXSTYLE = -20;
    public const int WS_EX_TOOLWINDOW = 0x00000080;
}
"@

# �������� handle ����
$hwnd = (New-Object System.Windows.Interop.WindowInteropHelper $window).Handle

# ��������� ����� WS_EX_TOOLWINDOW, ����� �� ���������� ���� � ������ �����
$exStyle = [User32]::GetWindowLong($hwnd, [User32]::GWL_EXSTYLE)
$newStyle = $exStyle -bor [User32]::WS_EX_TOOLWINDOW
[User32]::SetWindowLong($hwnd, [User32]::GWL_EXSTYLE, $newStyle) | Out-Null

# ������� ��������� ���� ������ ����, ��� ���������
function Set-AlwaysOnTop {
    [WinAPI]::SetWindowPos($hwnd, [WinAPI]::HWND_TOPMOST, 0,0,0,0,
        [WinAPI]::SWP_NOMOVE -bor [WinAPI]::SWP_NOSIZE -bor [WinAPI]::SWP_NOACTIVATE) | Out-Null
}

# ������ ��� ���������� ��������� ���� ������� ������ 500 ��
$topmostTimer = New-Object System.Windows.Threading.DispatcherTimer
$topmostTimer.Interval = [TimeSpan]::FromMilliseconds(500)
$topmostTimer.Add_Tick({ Set-AlwaysOnTop })
$topmostTimer.Start()

# ���������� ����
$window.ShowDialog() | Out-Null
