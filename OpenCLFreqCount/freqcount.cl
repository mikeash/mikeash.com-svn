
__kernel void freqcount(const unsigned char *input, unsigned char *output)
{
    const uint index = get_global_id(0);
    const uint start = index * 256;
    for(uint i = 0; i < 256; i++)
    {
        uint value = input[start + i];
        output[start + value]++;
    }
}

__kernel void freqsum(const unsigned int count, unsigned char *freqs, unsigned int *totals)
{
    const uint index = get_global_id(0);
    for(uint i = 0; i < count; i++)
        totals[index] += freqs[index + i * 256];
}
