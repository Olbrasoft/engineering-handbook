# Azure Speech-to-Text (Cognitive Services)

> Official Microsoft speech recognition API for converting spoken audio to text

**Provider**: Microsoft Azure
**Service**: Azure Cognitive Services - Speech
**Website**: https://azure.microsoft.com/en-us/products/ai-services/ai-speech
**Documentation**: https://learn.microsoft.com/en-us/azure/ai-services/speech-service/

---

## Table of Contents

1. [Overview](#overview)
2. [Pricing Tiers](#pricing-tiers)
3. [API Endpoints](#api-endpoints)
4. [Usage Limits](#usage-limits)
5. [API Keys](#api-keys)
6. [Usage Tracking](#usage-tracking)
7. [Rate Limits](#rate-limits)
8. [Billing and Reset](#billing-and-reset)
9. [Supported Languages](#supported-languages)
10. [Code Examples](#code-examples)
11. [Troubleshooting](#troubleshooting)

---

## Overview

Azure Speech-to-Text (formerly known as Speech Recognition) converts spoken audio to text in real-time or from audio files.

**Key Features**:
- ✅ High accuracy speech recognition
- ✅ Real-time and batch processing
- ✅ Support for 100+ languages and variants
- ✅ Custom speech models (trained on your data)
- ✅ Conversation transcription (speaker diarization)
- ✅ Punctuation and capitalization
- ✅ Profanity filtering options
- ✅ Free tier available (5 hours/month)

**Limitations**:
- ❌ **No usage tracking API** (same as Azure Translator)
- ❌ Requires Azure subscription (even for free tier)
- ⚠️ Must count audio minutes client-side

---

## Pricing Tiers

### Speech-to-Text Standard

| Tier | Monthly Cost | Audio Hours/Month | Price per Hour | Features |
|------|--------------|-------------------|----------------|----------|
| **Free (F0)** | €0 | 5 hours | Free | Standard recognition |
| **Standard (S0)** | Pay-as-you-go | Unlimited | €0.85/hour | + Custom models |

### Speech-to-Text Custom (trained models)

| Tier | Hosting Cost | Training | Adaptation | Endpoint Queries |
|------|--------------|----------|------------|------------------|
| **Custom** | €0.45/hour | €1.25/hour | €0.42/hour | €1.25/hour |

**Important Notes**:
- Free tier (F0): 5 hours of audio per month, **hard limit**
- When F0 limit reached, API returns **HTTP 403 (Forbidden)**
- Standard tier: Pay €0.85 per audio hour (60 minutes)
- Billing is per audio minute (minimum 1 second)

---

## API Endpoints

### REST API (Batch)

```
POST https://{region}.api.cognitive.microsoft.com/speechtotext/v3.0/transcriptions
```

**Regions**: `westeurope`, `northeurope`, `eastus`, etc.

**Use for**:
- Batch audio file transcription
- Long audio files (up to 2 hours per file)
- Asynchronous processing

### WebSocket API (Real-time)

```
wss://{region}.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1
```

**Use for**:
- Real-time speech recognition
- Live audio streams
- Interactive applications

**Required Headers**:
```
Ocp-Apim-Subscription-Key: YOUR_API_KEY
```

### Speech SDK

**Recommended**: Use Azure Speech SDK instead of raw API calls.

**Supported Platforms**:
- .NET / C#
- Python
- Java
- JavaScript / Node.js
- C++
- Objective-C / Swift

**NuGet Package** (.NET):
```bash
dotnet add package Microsoft.CognitiveServices.Speech --version 1.34.0
```

---

## Usage Limits

### Free Tier (F0)

| Limit Type | Value | Description |
|------------|-------|-------------|
| **Audio Hours/Month** | 5 hours (300 minutes) | Hard limit, strictly enforced |
| **Concurrent Requests** | 1 | Only 1 request at a time |
| **File Size** | 2 GB | Maximum audio file size |
| **Audio Duration** | 2 hours | Maximum per single file |

**Important**:
- When limit is reached, API returns **HTTP 403 (Forbidden)**
- Billing is per audio second (not per API call)
- 1 hour audio = 1 hour quota (regardless of how many chunks/requests)

### Standard Tier (S0)

| Limit Type | Value | Description |
|------------|-------|-------------|
| **Audio Hours/Month** | Unlimited | Pay-as-you-go |
| **Concurrent Requests** | 100 | Default (can be increased) |
| **File Size** | 2 GB | Maximum audio file size |
| **Audio Duration** | 2 hours | Maximum per single file |

---

## API Keys

### Our API Keys

**Location**: `~/Dokumenty/přístupy/api-keys.md` (Azure Speech section - if exists)

**Note**: If you don't have Azure Speech resource yet, you need to create one:

1. Go to https://portal.azure.com
2. Create new resource → AI + Machine Learning → Speech
3. Choose pricing tier (F0 for free)
4. Select region (e.g., West Europe)
5. Get API key from Keys and Endpoint section

**Resource Configuration**:
```
Resource Name: olbrasoft-speech (example)
Region: West Europe
Pricing Tier: F0 (Free)
Key 1: [64-character key]
Key 2: [64-character key]
Endpoint: https://westeurope.api.cognitive.microsoft.com/sts/v1.0/issuetoken
```

**Key Format**: Same as Azure Translator (64 characters)

**Multiple Keys**:
- Same behavior as Azure Translator
- Both keys **share the same quota** (5 hours total, NOT 10 hours)
- Use for load balancing and key rotation

---

## Usage Tracking

### ❌ No Native Usage API

**CRITICAL**: Azure Speech **does NOT provide a usage tracking API**.

Like Azure Translator, you must implement **client-side tracking**.

### Client-Side Tracking (Required)

**Implementation Example**:

```csharp
public class AzureSpeechUsageTracker
{
    private readonly IProviderUsageRepository _repository;

    public async Task RecordRecognitionAsync(TimeSpan audioDuration, CancellationToken ct)
    {
        // Count audio duration in seconds
        var durationSeconds = (int)audioDuration.TotalSeconds;

        var usage = await _repository.GetCurrentMonthUsageAsync("AzureSpeech", ct);

        if (usage == null)
        {
            usage = new ProviderUsage
            {
                Provider = "AzureSpeech",
                SecondsUsed = 0,
                SecondsLimit = 18_000,  // 5 hours = 300 minutes = 18,000 seconds
                BillingPeriodStart = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1),
                BillingPeriodEnd = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1)
                    .AddMonths(1).AddDays(-1)
            };
        }

        usage.SecondsUsed += durationSeconds;
        usage.LastUpdated = DateTime.UtcNow;

        await _repository.UpsertAsync(usage, ct);
    }

    public async Task<bool> HasSufficientQuotaAsync(TimeSpan requiredDuration, CancellationToken ct)
    {
        var usage = await _repository.GetCurrentMonthUsageAsync("AzureSpeech", ct);

        if (usage == null)
            return true; // No usage yet

        var remaining = usage.SecondsLimit - usage.SecondsUsed;
        return remaining >= requiredDuration.TotalSeconds;
    }
}
```

### Database Schema

**Table**: `ProviderUsage` (extended for speech)

```sql
CREATE TABLE ProviderUsage (
    Id BIGINT PRIMARY KEY IDENTITY(1,1),
    Provider NVARCHAR(50) NOT NULL,              -- 'AzureSpeech'
    CharactersUsed BIGINT NULL,                  -- For translation (NULL for speech)
    CharacterLimit BIGINT NULL,                  -- For translation (NULL for speech)
    SecondsUsed BIGINT NULL,                     -- For speech recognition
    SecondsLimit BIGINT NULL,                    -- For speech (18,000 = 5 hours for F0)
    BillingPeriodStart DATE NOT NULL,
    BillingPeriodEnd DATE NOT NULL,
    LastUpdated DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

    INDEX IX_Provider_Period (Provider, BillingPeriodStart)
);
```

**Example Data**:

| Provider | SecondsUsed | SecondsLimit | BillingPeriodStart | BillingPeriodEnd |
|----------|-------------|--------------|-------------------|------------------|
| AzureSpeech | 10,800 | 18,000 | 2025-12-01 | 2025-12-31 |

**Interpretation**:
- Used: 10,800 seconds = 180 minutes = 3 hours
- Limit: 18,000 seconds = 300 minutes = 5 hours
- Remaining: 7,200 seconds = 120 minutes = 2 hours (40% remaining)

### Azure Portal Metrics

**Non-realtime** monitoring via Azure Portal:

1. Go to https://portal.azure.com
2. Navigate to your Speech resource
3. Click "Metrics"
4. Select metric: **"Speech Recognition Duration"**
5. Set time range

**Limitations**: Same as Azure Translator (delayed, not real-time)

---

## Rate Limits

### Official Limits

**Sources**:
- [Azure Speech Service Quotas and Limits](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/speech-services-quotas-and-limits)
- [Azure Cognitive Services Rate Limits](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/speech-services-quotas-and-limits#general-best-practices-to-mitigate-throttling)

### Free Tier (F0)

| Limit Type | Value | Notes |
|------------|-------|-------|
| **Concurrent Requests** | 1 | Only 1 recognition at a time |
| **Transactions/Second** | 20 | Per endpoint |
| **Transactions/10 Seconds** | 200 | Per endpoint |
| **Audio Quota** | 5 hours/month | Hard limit (HTTP 403 when exceeded) |

**Critical Constraint**: Free tier allows only **1 concurrent request**.
- Trying to start 2nd request while 1st is running → **HTTP 429 (Too Many Requests)**
- **Must implement queue** for batch processing multiple audio files
- Processing time depends on audio duration (real-time or faster)

### Standard Tier (S0)

| Limit Type | Value | Notes |
|------------|-------|-------|
| **Concurrent Requests** | 100 | Default (can be increased via support) |
| **Transactions/Second** | 200 | Higher than F0 |
| **Transactions/10 Seconds** | 2,000 | Higher than F0 |
| **Audio Quota** | Unlimited | Pay-as-you-go (€0.85/hour) |

---

### Recommended Delays for Batch Processing

**Key Constraint**: Free tier (F0) = **1 concurrent request only**.

**Strategy**: Sequential processing with queue (NOT parallel processing).

| Scenario | Audio Duration | Processing Time | Recommended Delay | Notes |
|----------|----------------|-----------------|-------------------|-------|
| **Tiny files** (< 10 seconds) | 5-10s | ~5-10s | 15-20s total | Processing + buffer |
| **Short files** (10-30 seconds) | 10-30s | ~10-30s | 35-60s total | Wait for completion |
| **Medium files** (30-120 seconds) | 30-120s | ~30-120s | 2-4 minutes total | Ensure full processing |
| **Long files** (2-10 minutes) | 2-10 min | ~2-10 min | 12-20 minutes total | Max safe processing |
| **Very long files** (10+ minutes) | 10+ min | ~10+ min | Duration + 20% | Add safety margin |

**Processing Time Calculation**:
```
Total Time = Audio Duration + API Overhead + Safety Buffer
API Overhead = ~1-2 seconds (connection, initialization)
Safety Buffer = 10-20% of audio duration
```

**Important**: Azure Speech typically processes audio in **real-time or faster** (1x-2x speed), but you must wait for the request to fully complete before starting the next one.

---

### Batch Processing Implementation

**Queue-Based Approach** (Required for F0):

```csharp
public class AzureSpeechBatchProcessor
{
    private readonly SemaphoreSlim _semaphore = new SemaphoreSlim(1, 1); // Only 1 concurrent
    private readonly AzureSpeechRecognizer _recognizer;

    public async Task<List<RecognitionResult>> ProcessBatchAsync(
        List<string> audioFiles,
        CancellationToken ct)
    {
        var results = new List<RecognitionResult>();

        foreach (var file in audioFiles)
        {
            // Wait for slot (F0: max 1 concurrent)
            await _semaphore.WaitAsync(ct);

            try
            {
                Console.WriteLine($"Processing {file}...");

                var audioDuration = await GetAudioDurationAsync(file);
                var result = await _recognizer.RecognizeFromFileAsync(file);

                results.Add(new RecognitionResult
                {
                    FileName = file,
                    Text = result,
                    Duration = audioDuration
                });

                // Optional: Add delay between files (not strictly required for F0)
                // Azure will naturally delay due to 1 concurrent limit
                await Task.Delay(TimeSpan.FromSeconds(1), ct);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to process {file}: {ex.Message}");
                results.Add(new RecognitionResult
                {
                    FileName = file,
                    Error = ex.Message
                });
            }
            finally
            {
                _semaphore.Release();
            }
        }

        return results;
    }

    private async Task<TimeSpan> GetAudioDurationAsync(string filePath)
    {
        // Use NAudio or FFmpeg to get duration
        using var reader = new AudioFileReader(filePath);
        return reader.TotalTime;
    }
}
```

---

### Dynamic Delay Calculation (S0 Tier)

For Standard tier with 100 concurrent requests, you may want delays:

```csharp
public class SpeechRateLimiter
{
    private const int MAX_CONCURRENT_REQUESTS = 100; // S0 tier
    private const int TRANSACTIONS_PER_SECOND = 200; // S0 tier

    private readonly SemaphoreSlim _semaphore;

    public SpeechRateLimiter(int maxConcurrent = 1)
    {
        _semaphore = new SemaphoreSlim(maxConcurrent, maxConcurrent);
    }

    public TimeSpan CalculateDelay(TimeSpan audioDuration)
    {
        // For S0: Can process multiple files in parallel
        // No delay needed between requests if under concurrent limit

        // For F0: Sequential processing, no delay needed
        // (Azure enforces 1 concurrent automatically)

        return TimeSpan.Zero; // No artificial delay needed
    }

    public async Task<T> ExecuteWithRateLimitAsync<T>(
        Func<Task<T>> action,
        CancellationToken ct)
    {
        await _semaphore.WaitAsync(ct);

        try
        {
            return await action();
        }
        finally
        {
            _semaphore.Release();
        }
    }
}
```

**Usage**:
```csharp
var limiter = new SpeechRateLimiter(maxConcurrent: 1); // F0 tier

foreach (var file in audioFiles)
{
    var result = await limiter.ExecuteWithRateLimitAsync(
        async () => await RecognizeFromFileAsync(file),
        cancellationToken
    );
}
```

---

### Exponential Backoff (HTTP 429 Handling)

```csharp
public async Task<string> RecognizeWithRetryAsync(
    string audioFile,
    CancellationToken ct)
{
    var delay = TimeSpan.FromSeconds(2); // Start with 2s
    var maxRetries = 5;

    for (int i = 0; i < maxRetries; i++)
    {
        try
        {
            return await RecognizeFromFileAsync(audioFile);
        }
        catch (Exception ex) when (ex.Message.Contains("429") || ex.Message.Contains("Too Many Requests"))
        {
            if (i == maxRetries - 1)
                throw new InvalidOperationException(
                    $"Rate limit exceeded after {maxRetries} retries. " +
                    "Ensure only 1 concurrent request (F0) or wait longer.", ex);

            Console.WriteLine($"Rate limited. Waiting {delay.TotalSeconds}s before retry {i + 1}/{maxRetries}...");
            await Task.Delay(delay, ct);

            delay *= 2; // Exponential backoff: 2s, 4s, 8s, 16s, 32s
        }
    }

    throw new InvalidOperationException("Should not reach here");
}
```

---

### Parallel Processing (S0 Only)

**Warning**: Only for Standard tier (S0) with 100 concurrent requests.

```csharp
public async Task<List<RecognitionResult>> ProcessParallelAsync(
    List<string> audioFiles,
    CancellationToken ct)
{
    // S0 tier: Up to 100 concurrent
    var limiter = new SpeechRateLimiter(maxConcurrent: 50); // Conservative

    var tasks = audioFiles.Select(async file =>
    {
        return await limiter.ExecuteWithRateLimitAsync(
            async () =>
            {
                var result = await RecognizeFromFileAsync(file);
                return new RecognitionResult { FileName = file, Text = result };
            },
            ct
        );
    });

    return (await Task.WhenAll(tasks)).ToList();
}
```

**Do NOT use parallel processing on F0** - will immediately hit HTTP 429.

---

### Best Practices for Rate Limiting

1. **Always use SemaphoreSlim** to enforce concurrent request limit:
   - F0: `new SemaphoreSlim(1, 1)` - strictly 1 concurrent
   - S0: `new SemaphoreSlim(50, 100)` - conservative parallel

2. **Sequential processing is safest for F0**:
   - No artificial delays needed between files
   - Azure enforces 1 concurrent automatically
   - Just wait for previous request to complete

3. **Monitor processing time**:
   - Track how long each recognition takes
   - Audio duration ≈ processing time (typically 1x-2x speed)

4. **Implement exponential backoff**:
   - Start with 2s delay on HTTP 429
   - Double on each retry (2s → 4s → 8s → 16s → 32s)
   - Max 5 retries

5. **Consider Standard tier (S0) for production**:
   - 100 concurrent requests (vs F0's 1)
   - Higher transaction limits (200/s vs 20/s)
   - Worth it if processing many files regularly

6. **Track quota usage client-side**:
   - Azure Speech has no usage API
   - Count audio duration before each request
   - Store in database (`ProviderUsage` table)
   - Prevent HTTP 403 quota errors

---

### Common Rate Limit Errors

| Error Code | Message | Cause | Solution |
|------------|---------|-------|----------|
| **HTTP 429** | Too Many Requests | 2+ concurrent requests on F0 | Use SemaphoreSlim(1,1) queue |
| **HTTP 429** | Rate limit exceeded | Too many transactions/second | Add delays, exponential backoff |
| **HTTP 403** | Quota exceeded | Used all 5 hours (F0) | Wait until 1st of next month |
| **HTTP 403** | Invalid key | Wrong API key or region | Verify key in Azure Portal |

---

### Summary: F0 vs S0 Rate Limiting

| Aspect | Free (F0) | Standard (S0) |
|--------|-----------|---------------|
| **Concurrent Requests** | 1 (strict queue) | 100 (parallel OK) |
| **Transactions/Second** | 20 | 200 |
| **Recommended Strategy** | Sequential processing | Parallel with SemaphoreSlim |
| **Delays Needed** | No (queue enforces) | No (within limits) |
| **Retry on 429** | Yes (exponential backoff) | Yes (exponential backoff) |
| **Quota Tracking** | Client-side (5 hours) | Client-side (unlimited, pay) |

---

## Billing and Reset

### Reset Schedule

Same as Azure Translator: **Calendar month** basis.

- Reset time: Midnight UTC on 1st of each month
- Free tier: 5 hours quota resets monthly
- Unused hours do NOT carry over

**Example**:
```
Dec 29, 2025 - Used: 4.5 hours / 5 hours (0.5 hour remaining)
Jan 1, 2026 00:00 UTC - Used: 0 hours / 5 hours (reset!)
```

---

## Supported Languages

Azure Speech supports **100+ languages and variants**.

**Popular Languages**:

| Code | Language | Code | Language |
|------|----------|------|----------|
| `cs-CZ` | Czech (Czechia) | `pl-PL` | Polish |
| `de-DE` | German (Germany) | `pt-BR` | Portuguese (Brazil) |
| `en-US` | English (US) | `pt-PT` | Portuguese (Portugal) |
| `en-GB` | English (UK) | `ru-RU` | Russian |
| `es-ES` | Spanish (Spain) | `sk-SK` | Slovak |
| `fr-FR` | French (France) | `sv-SE` | Swedish |
| `it-IT` | Italian | `tr-TR` | Turkish |
| `ja-JP` | Japanese | `uk-UA` | Ukrainian |
| `ko-KR` | Korean | `zh-CN` | Chinese (Simplified) |
| `nl-NL` | Dutch | `zh-TW` | Chinese (Traditional) |

**Get full list**:
```bash
curl -X GET 'https://westeurope.tts.speech.microsoft.com/cognitiveservices/voices/list' | jq
```

---

## Code Examples

### Using Speech SDK (.NET)

**Recommended approach** for most applications.

```csharp
using Microsoft.CognitiveServices.Speech;
using Microsoft.CognitiveServices.Speech.Audio;

public class AzureSpeechRecognizer
{
    private readonly string _apiKey;
    private readonly string _region;

    public AzureSpeechRecognizer(string apiKey, string region = "westeurope")
    {
        _apiKey = apiKey;
        _region = region;
    }

    public async Task<string> RecognizeFromFileAsync(string audioFilePath)
    {
        var config = SpeechConfig.FromSubscription(_apiKey, _region);
        config.SpeechRecognitionLanguage = "cs-CZ"; // Czech

        using var audioInput = AudioConfig.FromWavFileInput(audioFilePath);
        using var recognizer = new SpeechRecognizer(config, audioInput);

        var result = await recognizer.RecognizeOnceAsync();

        if (result.Reason == ResultReason.RecognizedSpeech)
        {
            return result.Text;
        }
        else if (result.Reason == ResultReason.NoMatch)
        {
            throw new InvalidOperationException("No speech could be recognized");
        }
        else if (result.Reason == ResultReason.Canceled)
        {
            var cancellation = CancellationDetails.FromResult(result);
            throw new InvalidOperationException($"Recognition canceled: {cancellation.Reason}. {cancellation.ErrorDetails}");
        }

        throw new InvalidOperationException($"Unexpected result reason: {result.Reason}");
    }
}
```

### Real-time Recognition from Microphone

```csharp
public async Task<string> RecognizeFromMicrophoneAsync()
{
    var config = SpeechConfig.FromSubscription(_apiKey, _region);
    config.SpeechRecognitionLanguage = "cs-CZ";

    using var audioConfig = AudioConfig.FromDefaultMicrophoneInput();
    using var recognizer = new SpeechRecognizer(config, audioConfig);

    Console.WriteLine("Speak into your microphone...");

    var result = await recognizer.RecognizeOnceAsync();

    if (result.Reason == ResultReason.RecognizedSpeech)
    {
        Console.WriteLine($"Recognized: {result.Text}");
        return result.Text;
    }
    else
    {
        Console.WriteLine($"Recognition failed: {result.Reason}");
        return null;
    }
}
```

### Continuous Recognition with Events

```csharp
public async Task ContinuousRecognitionAsync()
{
    var config = SpeechConfig.FromSubscription(_apiKey, _region);
    config.SpeechRecognitionLanguage = "cs-CZ";

    using var audioConfig = AudioConfig.FromDefaultMicrophoneInput();
    using var recognizer = new SpeechRecognizer(config, audioConfig);

    var stopRecognition = new TaskCompletionSource<int>();

    recognizer.Recognizing += (s, e) =>
    {
        Console.WriteLine($"Recognizing: {e.Result.Text}");
    };

    recognizer.Recognized += (s, e) =>
    {
        if (e.Result.Reason == ResultReason.RecognizedSpeech)
        {
            Console.WriteLine($"Final: {e.Result.Text}");
        }
    };

    recognizer.Canceled += (s, e) =>
    {
        Console.WriteLine($"Canceled: {e.Reason}");
        stopRecognition.TrySetResult(0);
    };

    recognizer.SessionStopped += (s, e) =>
    {
        Console.WriteLine("Session stopped");
        stopRecognition.TrySetResult(0);
    };

    await recognizer.StartContinuousRecognitionAsync();

    Console.WriteLine("Press any key to stop...");
    Console.ReadKey();

    await recognizer.StopContinuousRecognitionAsync();
    await stopRecognition.Task;
}
```

### With Usage Tracking

```csharp
public async Task<string> RecognizeWithTrackingAsync(string audioFilePath)
{
    // Get audio duration
    var audioDuration = await GetAudioDurationAsync(audioFilePath);

    // Check quota before recognition
    if (!await _usageTracker.HasSufficientQuotaAsync(audioDuration, CancellationToken.None))
    {
        throw new InvalidOperationException(
            $"Insufficient Azure Speech quota. Required: {audioDuration.TotalMinutes:F2} minutes");
    }

    // Recognize
    var text = await RecognizeFromFileAsync(audioFilePath);

    // Record usage
    await _usageTracker.RecordRecognitionAsync(audioDuration, CancellationToken.None);

    return text;
}

private async Task<TimeSpan> GetAudioDurationAsync(string filePath)
{
    // Use NAudio or similar library to get audio duration
    using var reader = new AudioFileReader(filePath);
    return reader.TotalTime;
}
```

---

## Troubleshooting

### HTTP 403 - Forbidden

**Error**:
```
Access denied due to invalid subscription key or wrong API endpoint.
```

**Causes**:
1. Invalid API key
2. Wrong region
3. Quota exceeded (F0: 5 hours/month)

**Solution**:
1. Verify key in Azure Portal → Speech → Keys and Endpoint
2. Ensure region matches (e.g., `westeurope`)
3. Check usage in Azure Portal Metrics
4. If quota exceeded, wait until 1st of next month

---

### HTTP 429 - Too Many Requests

**Error**:
```
Rate limit exceeded.
```

**Cause**: Free tier (F0) allows only **1 concurrent request**.

**Solution**:
1. Wait for current recognition to complete
2. Implement request queuing
3. Upgrade to Standard (S0) for 100 concurrent requests

**Example Queue**:
```csharp
private readonly SemaphoreSlim _semaphore = new SemaphoreSlim(1, 1); // Only 1 concurrent

public async Task<string> QueuedRecognizeAsync(string audioFile)
{
    await _semaphore.WaitAsync();

    try
    {
        return await RecognizeFromFileAsync(audioFile);
    }
    finally
    {
        _semaphore.Release();
    }
}
```

---

### Recognition Returns Empty Result

**Symptom**: `ResultReason.NoMatch` - no speech recognized.

**Causes**:
1. Poor audio quality
2. Background noise
3. Wrong language specified
4. Unsupported audio format

**Solution**:
1. **Check audio format**:
   - Supported: WAV (PCM 16-bit, 16 kHz or 8 kHz, mono)
   - Convert if needed: `ffmpeg -i input.mp3 -ar 16000 -ac 1 output.wav`

2. **Reduce background noise**:
   - Use noise cancellation preprocessing
   - Record in quiet environment

3. **Verify language**:
   ```csharp
   config.SpeechRecognitionLanguage = "cs-CZ"; // Must match audio language
   ```

4. **Test with sample audio**:
   ```bash
   # Download sample audio
   wget https://raw.githubusercontent.com/Azure-Samples/cognitive-services-speech-sdk/master/samples/csharp/sharedcontent/console/whatstheweatherlike.wav
   ```

---

### Client-Side Tracking Inaccurate

**Problem**: Tracked usage doesn't match Azure billing.

**Solution**:
1. **Use accurate audio duration**:
   ```csharp
   // Use library like NAudio, FFmpeg, or TagLib to get exact duration
   using var reader = new AudioFileReader(filePath);
   var duration = reader.TotalTime; // Accurate duration
   ```

2. **Track ALL recognitions** (including failed ones):
   ```csharp
   var duration = await GetAudioDurationAsync(audioFile);

   try
   {
       var result = await RecognizeFromFileAsync(audioFile);
   }
   finally
   {
       // Always record usage (Azure charges even if recognition fails)
       await _usageTracker.RecordRecognitionAsync(duration, ct);
   }
   ```

3. **Verify monthly in Azure Portal**:
   - Check "Speech Recognition Duration" metric
   - Compare with client-side tracking
   - Adjust if needed

---

## Related Documentation

- [Azure Translator](../translation/azure-translator.md) - Text translation service
- [DeepL API](../translation/deepl.md) - Alternative translation with native usage tracking

---

**Last Updated**: 2025-12-29
**Maintainer**: Olbrasoft
