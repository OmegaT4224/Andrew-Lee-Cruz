/**
 * R2 Storage Operations Module
 * Handles quantum state storage in Cloudflare R2
 */

export async function uploadQuantumState(bucket: R2Bucket, violetState: any): Promise<void> {
  const key = `quantum-states/${violetState.violet_sequence_id}.json`;
  
  const metadata = {
    'creator-uid': 'ALC-ROOT-1010-1111-XCOV∞',
    'creator-email': 'allcatch37@gmail.com',
    'sequence-id': violetState.violet_sequence_id,
    'upload-timestamp': Date.now().toString()
  };

  await bucket.put(key, JSON.stringify(violetState, null, 2), {
    customMetadata: metadata,
    httpMetadata: {
      contentType: 'application/json'
    }
  });
}

export async function getQuantumState(bucket: R2Bucket, sequenceId: string): Promise<any | null> {
  const key = `quantum-states/${sequenceId}.json`;
  
  const object = await bucket.get(key);
  if (!object) {
    return null;
  }

  const text = await object.text();
  return JSON.parse(text);
}

export async function listQuantumStates(bucket: R2Bucket): Promise<string[]> {
  const objects = await bucket.list({
    prefix: 'quantum-states/'
  });

  return objects.objects.map(obj => obj.key.replace('quantum-states/', '').replace('.json', ''));
}