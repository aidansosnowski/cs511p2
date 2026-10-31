import sqlite3
import sys

def load_database(docs_path, postings_path, db_path):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    cursor.executescript("""
        DROP TABLE IF EXISTS postings;
        DROP TABLE IF EXISTS documents;

        CREATE TABLE documents (
            id INTEGER PRIMARY KEY,
            rank REAL NOT NULL,
            title TEXT NOT NULL
        );

        CREATE TABLE postings (
            term TEXT NOT NULL,
            article_id INTEGER NOT NULL,
            weight REAL NOT NULL,
            PRIMARY KEY (term, article_id)
        ) WITHOUT ROWID;
    """)

    with open(docs_path, "r", encoding="utf-8") as f:
        batch = []

        for line in f:
            article_id, rank, title = line.rstrip("\n").split("\t", 2)
            batch.append((int(article_id), float(rank), title))

            if len(batch) >= 10000:
                cursor.executemany(
                    "INSERT INTO documents VALUES (?, ?, ?)", batch
                )
                batch.clear()

        if batch:
            cursor.executemany(
                "INSERT INTO documents VALUES (?, ?, ?)", batch
            )

    # inverted index
    with open(postings_path, "r", encoding="utf-8") as f:
        batch = []

        for line in f:
            term, values = line.rstrip("\n").split("\t", 1)

            for posting in values.split(","):
                article_id, weight = posting.split(":")
                batch.append((term, int(article_id), float(weight)))

                if len(batch) >= 10000:
                    cursor.executemany(
                        "INSERT INTO postings VALUES (?, ?, ?)", batch
                    )
                    batch.clear()

        if batch:
            cursor.executemany(
                "INSERT INTO postings VALUES (?, ?, ?)", batch
            )

    conn.commit()
    conn.close()


if __name__ == "__main__":
    load_database(sys.argv[1], sys.argv[2], sys.argv[3])

