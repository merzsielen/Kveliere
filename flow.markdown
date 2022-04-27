---
title: Flow
---
<head>
<script src="/js/external/Chart.js/chart.js"></script>
</head>

Flow is a little tool I want to put together to sate a bit of a curiosity I've had recently with the idea of modelling language evolution. The basic premise is this: given different language "states"—particular combinations of phonology, phonotactics, etc—can we determine the most *probable* sound changes that might occur, basing our prediction on which sound changes will lead to a maximal distinctiveness between phonemes or collapse rather indistinct phonemes when the result yields relatively low levels of ambiguity. For example, if the distinction between a dental /s̪/ and an alveolar /s/ is important to a sizeable chunk of the lexicon, we might expect that distinction to be maintained; in contrast, these phonemes might collapse into one, likely /s/, if this will only give rise to a little ambiguity here and there. I want to stress that this isn't meant to perfectly accurately reflect language change. Languages are absolutely buck wild, and I won't pretend to be able to capture their fluidity and (frequent) disregard for ambiguity; Flow is only meant to be a sort of guide, a rule of thumb, for determining which sound changes it wouldn't be surprising to see a particular language undergo.

To do this, I'm going to have to mine various sources for info on the sound changes and language states we've seen in our own world. Note that this is, to some degree, a sample size of one. We can't (perhaps, yet) know the full range of potential sound changes that languages are capable of undergoing, given that we only have examples from our own history, though given the depth of our history it is fairly safe to say that this data set is diverse. This presents two problems: where to source our data and how to acquire it.

My initial intention was to use the [*Index Diachronica*](https://chridd.nfshost.com/diachronica/index-diachronica.pdf), but I'm honestly not psyched about the origin of some of its data. Most of it make use of verifiable, academic sources, but other sections draw only indirectly from such places or state no source at all.

# Test Chart

I want to check to see how slow Chart.js, so bear with me.

<div>
<canvas id="testChart" width="100px" height="100px"></canvas>
</div>

<script>
    var ctx = document.getElementById("testChart");
    const data = {
        datasets: [{
        label: 'm',
        data: [{
            x: -10,
            y: 0
        }],
        backgroundColor: 'rgb(255, 99, 132)'
        }],
    };
    const config = {
        type: 'scatter',
        data: data,
        options: {
            scales: {
                x: {
                    type: 'linear',
                    position: 'bottom'
                }
            }
        } 
    };
    const myChart = new Chart(
        ctx,
        config
    );
</script>