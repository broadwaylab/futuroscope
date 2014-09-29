module Futuroscope
  describe Pool do
    it "spins up a number of workers" do
      pool = Pool.new(2..4)
      expect(pool.workers).to have(2).workers

      pool = Pool.new(3..4)
      expect(pool.workers).to have(3).workers
    end

    describe "push" do
      it "enqueues a job and runs it" do
        pool = Pool.new
        future = Struct.new(:worker_thread).new(nil)

        expect(future).to receive :resolve!
        pool.push future
        sleep(0.1)
      end
    end

    describe "worker control" do
      it "adds more workers when needed and returns to the default amount" do
        pool = Pool.new(2..8)
        10.times do
          Future.new(pool){ sleep(1) }
        end

        sleep(0.5)
        expect(pool.workers).to have(8).workers

        sleep(3)
        expect(pool.workers).to have(2).workers
      end

      it "allows overriding min workers real time" do
        pool = Pool.new(2..8)
        pool.min_workers = 3
        expect(pool.workers).to have(3).workers
      end

      it "allows overriding max workers real time" do
        pool = Pool.new(2..8)
        allow(pool).to receive(:span_chance).and_return true
        pool.max_workers = 4

        10.times do |future|
          Future.new(pool){ sleep(1) }
        end

        sleep(0.5)
        expect(pool.workers).to have(4).workers
      end
    end

    describe "#finalize" do
      it "shuts down all its workers" do
        pool = Pool.new(2..8)

        pool.send(:finalize)

        expect(pool.workers).to have(0).workers
      end
    end
  end
end
