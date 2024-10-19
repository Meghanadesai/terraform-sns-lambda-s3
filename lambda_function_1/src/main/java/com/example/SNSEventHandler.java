package com.example;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.SNSEvent;
import com.amazonaws.services.lambda.runtime.events.SNSEvent.SNSRecord;

import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.time.Instant;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

public class SNSEventHandler implements RequestHandler<SNSEvent, Boolean> {
    private LambdaLogger logger;
    private final S3Client s3Client;
    private static final String BUCKET_NAME = "my-sns-lambda-bucket";

    public SNSEventHandler() {
        this.logger = null;
        this.s3Client = S3Client.builder().build();
    }

    @Override
    public Boolean handleRequest(SNSEvent event, Context context) {
        logger = context.getLogger();
        List<SNSRecord> records = event.getRecords();

        if (!records.isEmpty()) {
            Iterator<SNSRecord> recordsIter = records.iterator();
            while (recordsIter.hasNext()) {
                processRecord(recordsIter.next());
            }
        }
        return Boolean.TRUE;
    }

    public void processRecord(SNSRecord record) {
        try {
            String message = record.getSNS().getMessage();
            
            // Generate a unique key for the S3 object
            String objectKey = "sns-message-" + Instant.now().toEpochMilli() + "-" + UUID.randomUUID().toString() + ".txt";

            // Store the message in S3
            s3Client.putObject(PutObjectRequest.builder()
                    .bucket(BUCKET_NAME)
                    .key(objectKey)
                    .contentType("application/json")
                    .build(),
                    RequestBody.fromBytes(message.getBytes()));

        } catch (Exception e) {
            logger.log("Error processing record: " + e.getMessage());
            throw new RuntimeException(e);
        }
    }
}
