gluon-airtime
=============

Based on https://forum.freifunk.net/t/airtime-in-fluechtlingsunterkuenften/12333/9

Patches needed for Meshviewer etc.: https://github.com/Moorviper/meshviewer/commit/3722df966b2f8d717d4ee3b4deef86bb89745e7d

Note that “s/d.nodeinfo.network.wireless/d.nodeinfo.wireless/g” and “s%d.nodeinfo.network, \["wireless",%d.nodeinfo, ["wireless",%g” is needed against linked patch. (Data is pushed to nodeinfo.wireless, not nodeinfo.network.wireless!)

Script to measure airtime as seen from the nodes.
