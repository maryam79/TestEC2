import java.util.*;
import com.amazonaws.*;
import com.amazonaws.auth.*;
import com.amazonaws.auth.profile.*;
import com.amazonaws.regions.*;
import com.amazonaws.services.s3.*;
import com.amazonaws.services.s3.model.*;
 
public class TestS3
{
        public AmazonS3Client client;

        public TestS3()
        {
                client = new AmazonS3Client();
                client.configureRegion(Regions.AP_SOUTHEAST_2);
        }

        public void listBuckets()
        {
                try 
                {
			List<Bucket> buckets = client.listBuckets();
			for (Bucket bucket : buckets)
			{
				System.out.println(bucket.getName());
			}
                } catch (Exception e) 
                {
                        System.out.println(e.getMessage());
                        e.printStackTrace();
                }
        }

	public void listObjects(String bucket)
	{
                try 
                {
			ObjectListing listing = client.listObjects(bucket);
			List<S3ObjectSummary> objects = listing.getObjectSummaries();
			for (S3ObjectSummary object : objects)
			{
				System.out.println(object.getKey());
			}

			if (listing.isTruncated())
			{
				System.out.println("This is a truncated list.");
			}
			else
			{
				System.out.println("This is a complete list.");
			}
                } catch (Exception e) 
                {
                        System.out.println(e.getMessage());
                        e.printStackTrace();
                }
	}

        public static void main(String[] args)
        {
                TestS3 test = new TestS3();
                test.listBuckets();
		test.listObjects(args[0]);
        }
}
