<style>
  .rectangle {
    animation: flicker 1s infinite;
    -webkit-animation: flicker 1s infinite;
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    background: gray;
    transition: all 1ms;
  }
  @-webkit-keyframes flicker {
    2.50% { opacity: 0; }
    5.00% { opacity: 1; }
    7.50% { opacity: 0; }
    10.00% { opacity: 1; }
    12.50% { opacity: 0; }
    15.00% { opacity: 1; }
    17.50% { opacity: 0; }
    20.00% { opacity: 1; }
    22.50% { opacity: 0; }
    25.00% { opacity: 1; }
    27.50% { opacity: 0; }
    30.00% { opacity: 1; }
    32.50% { opacity: 0; }
    35.00% { opacity: 1; }
    37.50% { opacity: 0; }
    40.00% { opacity: 1; }
    42.50% { opacity: 0; }
    45.00% { opacity: 1; }
    47.50% { opacity: 0; }
    50.00% { opacity: 1; }
    52.50% { opacity: 0; }
    55.00% { opacity: 1; }
    57.50% { opacity: 0; }
    60.00% { opacity: 1; }
    62.50% { opacity: 0; }
    65.00% { opacity: 1; }
    67.50% { opacity: 0; }
    70.00% { opacity: 1; }
    72.50% { opacity: 0; }
    75.00% { opacity: 1; }
    77.50% { opacity: 0; }
    80.00% { opacity: 1; }
    82.50% { opacity: 0; }
    85.00% { opacity: 1; }
    87.50% { opacity: 0; }
    90.00% { opacity: 1; }
    92.50% { opacity: 0; }
    95.00% { opacity: 1; }
    97.50% { opacity: 0; }
    100.00% { opacity: 1; }
  }
  @keyframes flicker {
    2.50% { opacity: 0; }
    5.00% { opacity: 1; }
    7.50% { opacity: 0; }
    10.00% { opacity: 1; }
    12.50% { opacity: 0; }
    15.00% { opacity: 1; }
    17.50% { opacity: 0; }
    20.00% { opacity: 1; }
    22.50% { opacity: 0; }
    25.00% { opacity: 1; }
    27.50% { opacity: 0; }
    30.00% { opacity: 1; }
    32.50% { opacity: 0; }
    35.00% { opacity: 1; }
    37.50% { opacity: 0; }
    40.00% { opacity: 1; }
    42.50% { opacity: 0; }
    45.00% { opacity: 1; }
    47.50% { opacity: 0; }
    50.00% { opacity: 1; }
    52.50% { opacity: 0; }
    55.00% { opacity: 1; }
    57.50% { opacity: 0; }
    60.00% { opacity: 1; }
    62.50% { opacity: 0; }
    65.00% { opacity: 1; }
    67.50% { opacity: 0; }
    70.00% { opacity: 1; }
    72.50% { opacity: 0; }
    75.00% { opacity: 1; }
    77.50% { opacity: 0; }
    80.00% { opacity: 1; }
    82.50% { opacity: 0; }
    85.00% { opacity: 1; }
    87.50% { opacity: 0; }
    90.00% { opacity: 1; }
    92.50% { opacity: 0; }
    95.00% { opacity: 1; }
    97.50% { opacity: 0; }
    100.00% { opacity: 1; }
  }
</style>

<script>
  let started = false;
  let playing = false;
  const context = new AudioContext();
  const gainNode = context.createGain();
  const oscillator = context.createOscillator();
  oscillator.frequency.value = 40;
  oscillator.connect(gainNode);
  gainNode.connect(context.destination);

  function toggle() {
    if (!started) {
      oscillator.start();
      started = true;
    }
    if (playing) {
      context.suspend();
      playing = false;
    } else {
      context.resume();
      playing = true;
    }
  };
</script>

<div class="rectangle" on:click={toggle} />
