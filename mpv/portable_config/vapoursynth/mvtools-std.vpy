### MOD of https://gist.github.com/KCCat/1b3a7b7f085a066af3719859f88ded02
### 中等消耗。偏保守型补帧策略

import vapoursynth as vs
from vapoursynth import core

clip = video_in
vfps = int(container_fps*1e8)
dfps = 60000

##dfps = 设置为你的目标帧率，例 60000 即约60fps。特殊值例如 display_fps/2*1000 即目标为显示器刷新率的一半帧率，值填 container_fps*2*1000 即倍帧
##更高的帧率更加耗能，产生更多伪影，通常是不必要的。例如对于144hz的显示器来说，最多只需要补到72fps，剩下的让mpv.conf中的 --interpolation 平滑过渡到144fps

def ffps(fps) :
    rfps = int('%.0f' % fps)
    if ( abs(fps - (rfps/1.001)) < abs(fps - (rfps/1.000)) ):
        vfps,vden = rfps*1000, 1001
    else:
        vfps,vden = rfps*1000, 1000
    return vfps, vden


if (container_fps < 32) :
    vfps,vden = ffps(container_fps)
    print(container_fps, vfps, vden)

    clip = core.std.AssumeFPS(clip, fpsnum=int(vfps), fpsden=vden)
    _super  = core.mv.Super(clip, pel=2, sharp=1, rfilter=4,hpad=8,vpad=8,levels=0)
    mvbw = core.mv.Analyse(super=_super, blksize=32, levels=0, search=4, searchparam=0, pelsearch=3, isb=True, _lambda=0, lsad=10000, overlap=0, overlapv=4, badrange=0, search_coarse=4)
    mvfw = core.mv.Analyse(super=_super, blksize=32, levels=0, search=4, searchparam=0, pelsearch=3, isb=False, _lambda=0, lsad=10000, overlap=0, overlapv=4, badrange=0, search_coarse=4)

    clip = core.mv.BlockFPS(clip, _super, mvbw, mvfw, num=dfps, den=vden, mode=2, ml=100.0, thscd1=970, thscd2=255, blend=False)

    clip.set_output()
