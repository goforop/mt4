<chart>
id=131221527302552380
symbol=EURCAD
period=1440
leftpos=1979
digits=5
scale=4
graph=1
fore=0
grid=0
volume=0
scroll=1
shift=1
ohlc=1
one_click=0
one_click_btn=1
askline=0
days=0
descriptions=0
shift_size=20
fixed_pos=0
window_left=240
window_top=-4
window_right=654
window_bottom=696
window_type=1
background_color=16777215
foreground_color=0
barup_color=7451452
bardown_color=255
bullcandle_color=7451452
bearcandle_color=255
chartline_color=0
volumes_color=32768
grid_color=12632256
askline_color=17919
stops_color=17919

<window>
height=100
fixed_height=0
<indicator>
name=main
</indicator>
<indicator>
name=Moving Average
period=9
shift=0
method=0
apply=0
color=255
style=0
weight=2
period_flags=0
show_data=1
</indicator>
<indicator>
name=Moving Average
period=50
shift=0
method=0
apply=0
color=0
style=0
weight=3
period_flags=0
show_data=1
</indicator>
<indicator>
name=Moving Average
period=14
shift=0
method=0
apply=0
color=13382297
style=0
weight=2
period_flags=0
show_data=1
</indicator>
<indicator>
name=Bollinger Bands
period=50
shift=0
deviations=1.618000
apply=0
color=8388608
style=0
weight=1
period_flags=0
show_data=1
</indicator>
<indicator>
name=Ichimoku Kinko Hyo
tenkan=9
kijun=50
senkou=200
color=16777215
style=0
weight=1
color2=16777215
style2=0
weight2=1
color3=0
style3=0
weight3=1
color4=64636
style4=2
weight4=1
color5=255
style5=2
weight5=1
period_flags=0
show_data=1
</indicator>
</window>

<window>
height=50
fixed_height=0
<indicator>
name=Stochastic Oscillator
kperiod=45
dperiod=3
slowing=3
method=0
apply=0
color=9109504
style=0
weight=2
color2=16777215
style2=0
weight2=1
min=0.00000000
max=100.00000000
levels_color=0
levels_style=0
levels_weight=1
level_0=20.00000000
level_1=80.00000000
period_flags=0
show_data=1
</indicator>
<indicator>
name=Stochastic Oscillator
kperiod=9
dperiod=3
slowing=3
method=0
apply=0
color=255
style=0
weight=2
color2=16777215
style2=0
weight2=2
min=0.00000000
max=100.00000000
levels_color=0
levels_style=2
levels_weight=1
level_0=20.00000000
level_1=80.00000000
level_2=40.00000000
level_3=60.00000000
period_flags=0
show_data=1
</indicator>
</window>

<window>
height=50
fixed_height=0
<indicator>
name=Custom Indicator
<expert>
name=RSI
flags=275
window_num=3
<inputs>
InpRSIPeriod=14
</inputs>
</expert>
shift_0=0
draw_0=0
color_0=0
style_0=0
weight_0=2
min=0.00000000
max=100.00000000
levels_color=0
levels_style=2
levels_weight=1
level_0=33.00000000
level_1=67.00000000
period_flags=0
show_data=1
</indicator>
<indicator>
name=Moving Average
period=9
shift=0
method=0
apply=8
color=255
style=0
weight=1
period_flags=0
show_data=1
</indicator>
<indicator>
name=Moving Average
period=45
shift=0
method=0
apply=8
color=13434880
style=0
weight=1
period_flags=0
show_data=1
</indicator>
</window>

<window>
height=50
fixed_height=0
<indicator>
name=Custom Indicator
<expert>
name=CII
flags=339
window_num=3
<inputs>
RSI.Price=0
RSI.SlowLength=45
RSI.FastLength=9
Momentum.Length=9
SMA.Length1=3
SMA.Length2=14
SMA.Length3=45
</inputs>
</expert>
shift_0=0
draw_0=0
color_0=0
style_0=0
weight_0=2
shift_1=0
draw_1=0
color_1=255
style_1=0
weight_1=0
shift_2=0
draw_2=0
color_2=13434880
style_2=0
weight_2=0
period_flags=0
show_data=1
</indicator>
</window>
</chart>

