require 'spec_helper'

describe "BackburnerSpec Matchers" do
  before do
    BackburnerSpec.reset!
  end

  let(:first_name) { 'Les' }
  let(:last_name) { 'Hill' }

  describe "#have_enqueued" do
    context "queued with a class" do
      before do
        Backburner.enqueue(Person, first_name, last_name)
      end

      subject { Person }

      it { should have_enqueued(first_name, last_name) }
      it { should_not have_enqueued(last_name, first_name) }
    end

    context "#in" do

      before do
        Backburner::Worker.enqueue(Person, [first_name, last_name], {queue: :new_tube} )
      end

      subject { Person }

      context "with #in(queue_name)" do
        it { should have_enqueued(first_name, last_name).in('new_tube') }
        it { should_not have_enqueued(last_name, first_name).in('new_tube') }
      end

      context "without #in(:places) after #in(:people)" do
        before { should have_enqueued(first_name, last_name).in('new_tube') }
        before { Backburner.enqueue(Place) }
        specify { Place.should have_enqueued }
      end
    end

    context "#times" do

      subject { Person }

      context "job queued once" do
        before do
          Backburner.enqueue(Person, first_name, last_name)
        end

        it { should_not have_enqueued(first_name, last_name).times(0) }
        it { should have_enqueued(first_name, last_name).times(1) }
        it { should_not have_enqueued(first_name, last_name).times(2) }
      end

      context "no job queued" do
        it { should have_enqueued(first_name, last_name).times(0) }
        it { should_not have_enqueued(first_name, last_name).times(1) }
      end
    end

    context "#once" do

      subject { Person }

      context "job queued once" do
        before do
          Backburner.enqueue(Person, first_name, last_name)
        end

        it { should have_enqueued(first_name, last_name).once }
      end

      context "no job queued" do
        it { should_not have_enqueued(first_name, last_name).once }
      end
    end
  end

  describe "#have_performed" do
    context "performed without arguments" do
      before do
        Order.async().method_without_args
      end

      subject { Order }

      it { should have_performed(:method_without_args) }
      it { should_not have_enqueued(:method_with_args) }
    end

    context "performed with arguments" do
      before do
        Order.async().method_with_args(1,2)
      end

      subject { Order }

      it { should have_performed(:method_with_args) }
      it { should have_performed(:method_with_args).with(1,2) }
      it { should_not have_performed(:method_withot_args) }
      it { should_not have_performed(:method_with_args).with(2,1) }
    end

    context "#in" do

      before do
        Order.async(queue: 'new_tube').method_without_args
      end

      subject { Order }

      context "with #in(queue_name)" do
        it { should have_performed(:method_without_args).in('new_tube') }
        it { should_not have_performed(:method_with_args).in('new_tube') }
      end
    end

    context "#times" do

      subject { Person }

      context "job queued once" do
        before do
          Backburner.enqueue(Person, first_name, last_name)
        end

        it { should_not have_enqueued(first_name, last_name).times(0) }
        it { should have_enqueued(first_name, last_name).times(1) }
        it { should_not have_enqueued(first_name, last_name).times(2) }
      end

      context "no job queued" do
        it { should have_enqueued(first_name, last_name).times(0) }
        it { should_not have_enqueued(first_name, last_name).times(1) }
      end
    end

    context "#once" do

      subject { Person }

      context "job queued once" do
        before do
          Backburner.enqueue(Person, first_name, last_name)
        end

        it { should have_enqueued(first_name, last_name).once }
      end

      context "no job queued" do
        it { should_not have_enqueued(first_name, last_name).once }
      end
    end
  end


  describe "#have_queue_size_of" do
    context "when nothing is queued" do
      subject { Person }

      it "raises the approrpiate exception" do
        expect do
          should have_queue_size_of(1)
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "queued with a class" do
      before do
        Backburner.enqueue(Person, first_name, last_name)
      end

      subject { Person }

      it { should have_queue_size_of(1) }
    end
  end

  describe "#have_queue_size_of_at_least" do
    context "when nothing is queued" do
      subject { Person }

      it "raises the approrpiate exception" do
        expect do
          should have_queue_size_of_at_least(1)
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "queued with a class" do
      before do
        Backburner.enqueue(Person, first_name, last_name)
      end

      subject { Person }

      it { should have_queue_size_of_at_least(1) }
    end
  end

  describe "#in" do
    before do
      Backburner::Worker.enqueue(Person, [first_name, last_name], queue: 'people')
    end

    subject { Person }

    context "with #in('queue_name')" do
      it { should have_queue_size_of(1).in('people') }
    end
  end

  # describe "#have_scheduled_at" do
  #   pending
  #   let(:scheduled_at) { Time.now + 5 * 60 }

  #   before do
  #     Backburner.enqueue_at(scheduled_at, Person, first_name, last_name)
  #   end

  #   it "returns true if the arguments are found in the queue" do
  #     Person.should have_scheduled_at(scheduled_at, first_name, last_name)
  #   end

  #   it "returns true if the arguments are found in the queue with anything matcher" do
  #     Person.should have_scheduled_at(scheduled_at, anything, anything)
  #     Person.should have_scheduled_at(scheduled_at, anything, last_name)
  #     Person.should have_scheduled_at(scheduled_at, first_name, anything)
  #   end

  #   it "returns false if the arguments are not found in the queue" do
  #     Person.should_not have_scheduled_at(scheduled_at, last_name, first_name)
  #   end
  # end

  # describe "#have_scheduled" do
  #   pending

  #   let(:scheduled_at) { Time.now + 5 * 60 }

  #   before do
  #     Backburner.enqueue_at(scheduled_at, Person, first_name, last_name)
  #   end

  #   it "returns true if the arguments are found in the queue" do
  #     Person.should have_scheduled(first_name, last_name)
  #   end

  #   it "returns true if arguments are found in the queue with anything matcher" do
  #     Person.should have_scheduled(anything, anything).at(scheduled_at)
  #     Person.should have_scheduled(anything, last_name).at(scheduled_at)
  #     Person.should have_scheduled(first_name, anything).at(scheduled_at)
  #   end

  #   it "returns false if the arguments are not found in the queue" do
  #     Person.should_not have_scheduled(last_name, first_name)
  #   end

  #   context "with #at(timestamp)" do
  #     it "returns true if arguments and timestamp matches positive expectation" do
  #       Person.should have_scheduled(first_name, last_name).at(scheduled_at)
  #     end

  #     it "returns true if arguments and timestamp matches negative expectation" do
  #       Person.should_not have_scheduled(first_name, last_name).at(scheduled_at + 5 * 60)
  #     end
  #   end

  #   context "with #in(interval)" do
  #     let(:interval) { 10 * 60 }

  #     before(:each) do
  #       Backburner.enqueue_in(interval, Person, first_name, last_name)
  #     end

  #     it "returns true if arguments and interval matches positive expectation" do
  #       Person.should have_scheduled(first_name, last_name).in(interval)
  #     end

  #     it "returns true if arguments and interval matches negative expectation" do
  #       Person.should_not have_scheduled(first_name, last_name).in(interval + 5 * 60)
  #     end
  #   end

  #   context "with #queue(queue_name)" do
  #     let(:interval) { 10 * 60 }

  #     before(:each) do
  #       Backburner.enqueue_in_with_queue(:test_queue, interval, NoQueueClass, 1)
  #     end

  #     it "uses queue from chained method" do
  #       NoQueueClass.should have_scheduled(1).in(interval).queue(:test_queue)
  #     end
  #   end
  # end

  # describe "#have_schedule_size_of" do
  #   before do
  #     Backburner.enqueue_at(Time.now + 5 * 60, Person, first_name, last_name)
  #   end

  #   it "raises the approrpiate exception" do
  #     lambda {
  #       Person.should have_schedule_size_of(2)
  #     }.should raise_error(RSpec::Expectations::ExpectationNotMetError)
  #   end

  #   it "returns true if actual schedule size matches positive expectation" do
  #     Person.should have_schedule_size_of(1)
  #   end

  #   it "returns true if actual schedule size matches negative expectation" do
  #     Person.should_not have_schedule_size_of(2)
  #   end

  #   context "with #queue(queue_name)" do
  #     before(:each) do
  #       Backburner.enqueue_in_with_queue(:test_queue, 10 * 60, NoQueueClass, 1)
  #     end

  #     it "returns true if actual schedule size matches positive expectation" do
  #       NoQueueClass.should have_schedule_size_of(1).queue(:test_queue)
  #     end
  #   end
  # end

  # describe "#have_schedule_size_of_at_least" do
  #   before do
  #     Backburner.enqueue_at(Time.now + 5 * 60, Person, first_name, last_name)
  #   end

  #   it "raises the approrpiate exception" do
  #     lambda {
  #       Person.should have_schedule_size_of_at_least(2)
  #     }.should raise_error(RSpec::Expectations::ExpectationNotMetError)
  #   end

  #   it "returns true if actual schedule size matches positive expectation" do
  #     Person.should have_schedule_size_of_at_least(1)
  #   end

  #   it "returns true if actual schedule size matches negative expectation" do
  #     Person.should_not have_schedule_size_of_at_least(5)
  #   end

  #   context "with #queue(queue_name)" do
  #     before(:each) do
  #       Backburner.enqueue_in_with_queue(:test_queue, 10 * 60, NoQueueClass, 1)
  #     end

  #     it "returns true if actual schedule size matches positive expectation" do
  #       NoQueueClass.should have_schedule_size_of_at_least(1).queue(:test_queue)
  #     end
  #   end

  # end
end