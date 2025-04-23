from sentence_transformers import SentenceTransformer, util
import sys
model = SentenceTransformer('all-MiniLM-L6-v2')

def check_plagiarism(text1, text2):
    embeddings = model.encode([text1, text2])
    similarity = util.cos_sim(embeddings[0], embeddings[1])
    return similarity.item()

# Example usage
text1 = sys.argv[1]
text2 = sys.argv[2]
similarity_score = check_plagiarism(text1, text2)
print(similarity_score)